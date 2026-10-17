import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/tree_record.dart';
import '../services/tree_storage.dart';

import 'dashboard.dart';
import 'tree_diary.dart';
import 'insights.dart';
import 'about_screen.dart';
import 'add_tree_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final List<TreeRecord> trees = [];
  final TreeStorage storage = TreeStorage();

  int selected = 0;

  bool loaded = false;
  bool storageReady = false;

  Future<void> pendingSave = Future<void>.value();

  String? storageError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loaded = false;
        storageError = null;
      });
    }

    try {
      final restored = await storage.load();

      if (!mounted) {
        return;
      }

      setState(() {
        trees
          ..clear()
          ..addAll(restored);

        storageReady = true;
        storageError = null;
      });
    } } catch (error, stackTrace) {
  debugPrint('GreenRoots storage load failed: $error');
  debugPrintStack(stackTrace: stackTrace);

  if (mounted) {
    setState(() {
      storageReady = false;
      storageError = 'Storage error:\n$error';
    });
  }
} finally {
      if (mounted) {
        setState(() {
          loaded = true;
        });
      }
    }
  }

  void _persist() {
    if (!storageReady) {
      return;
    }

    final snapshot = List<TreeRecord>.of(trees);

    pendingSave = pendingSave.then((_) async {
      try {
        await storage.save(snapshot);
      } catch (error) {
        debugPrint('GreenRoots storage save failed: $error');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Saving failed. Your changes may not persist.',
              ),
            ),
          );
        }
      }
    });
  }

  void _add(TreeRecord tree) {
    if (!storageReady) {
      return;
    }

    setState(() {
      trees.insert(0, tree);
      selected = 1;
    });

    _persist();
  }

  void _delete(TreeRecord tree) {
    if (!storageReady) {
      return;
    }

    setState(() {
      trees.removeWhere((t) => t.id == tree.id);
    });

    _persist();
  }

  void _toggle(TreeRecord tree) {
    if (!storageReady) {
      return;
    }

    final index = trees.indexWhere((t) => t.id == tree.id);

    if (index < 0) {
      return;
    }

    setState(() {
      trees[index] = tree.copyWith(
        needsCare: !tree.needsCare,
      );
    });

    _persist();
  }

  void _openAdd() {
    if (!storageReady) {
      _load();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddTreeScreen(
          onSave: _add,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(
        trees: trees,
        onAdd: _openAdd,
        onShowTrees: () {
          setState(() {
            selected = 1;
          });
        },
      ),
      TreeDiary(
        trees: trees,
        onAdd: _openAdd,
        onDelete: _delete,
        onToggle: _toggle,
      ),
      Insights(trees: trees),
      const AboutScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: !loaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : storageError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storage_outlined,
                            size: 48,
                            color: forest,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            storageError!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : IndexedStack(
                    index: selected,
                    children: pages,
                  ),
      ),
      floatingActionButton: selected < 2 && storageReady
          ? FloatingActionButton(
              onPressed: _openAdd,
              backgroundColor: forest,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: selected,
        indicatorColor: const Color(0xFFDDEBD7),
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          setState(() {
            selected = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'My Trees',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
