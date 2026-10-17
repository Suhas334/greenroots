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

  String? storageError;

  Future<void> pendingSave = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load existing trees from local storage.
  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loaded = false;
      storageError = null;
    });

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
    } catch (error, stackTrace) {
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

  // Save changes in sequence to avoid overlapping writes.
  void _persist() {
    if (!storageReady) {
      return;
    }

    final snapshot = List<TreeRecord>.of(trees);

    pendingSave = pendingSave.then((_) async {
      try {
        await storage.save(snapshot);
      } catch (error, stackTrace) {
        debugPrint('GreenRoots storage save failed: $error');
        debugPrintStack(stackTrace: stackTrace);

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

  // Add a new tree.
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

  // Delete a tree.
  void _delete(TreeRecord tree) {
    if (!storageReady) {
      return;
    }

    setState(() {
      trees.removeWhere((item) => item.id == tree.id);
    });

    _persist();
  }

  // Update the care status of a tree.
  void _toggle(TreeRecord tree) {
    if (!storageReady) {
      return;
    }

    final index = trees.indexWhere(
      (item) => item.id == tree.id,
    );

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

  // Open the Add Tree screen.
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
      Insights(
        trees: trees,
      ),
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
                    child: SingleChildScrollView(
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
                          const Text(
                            'Unable to load saved trees',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            storageError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
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
