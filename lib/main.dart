import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const forest = Color(0xFF245A3B);
const sage = Color(0xFF93AB73);
const canvas = Color(0xFFF5F8F1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GreenRootsApp());
}

class TreeRecord {
  final String id, name, species, location, notes;
  final DateTime planted;
  final double height;
  final bool needsCare;
  const TreeRecord(
      {required this.id,
      required this.name,
      required this.species,
      required this.location,
      required this.notes,
      required this.planted,
      required this.height,
      required this.needsCare});
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'location': location,
        'notes': notes,
        'planted': planted.toIso8601String(),
        'height': height,
        'needsCare': needsCare
      };
  factory TreeRecord.fromJson(Map<String, dynamic> j) => TreeRecord(
      id: j['id'] as String,
      name: j['name'] as String,
      species: j['species'] as String? ?? '',
      location: j['location'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
      planted: DateTime.parse(j['planted'] as String),
      height: (j['height'] as num?)?.toDouble() ?? 0,
      needsCare: j['needsCare'] as bool? ?? false);
  TreeRecord copyWith({bool? needsCare}) => TreeRecord(
      id: id,
      name: name,
      species: species,
      location: location,
      notes: notes,
      planted: planted,
      height: height,
      needsCare: needsCare ?? this.needsCare);
}

class GreenRootsApp extends StatelessWidget {
  const GreenRootsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenRoots',
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: canvas,
          colorScheme: ColorScheme.fromSeed(
              seedColor: forest, primary: forest, surface: canvas),
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationThemeData(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(17)),
          cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)))),
      home: const RootScreen());
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final List<TreeRecord> trees = [];
  int selected = 0;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('trees_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final restored = <TreeRecord>[];
          for (final item in decoded) {
            try {
              restored.add(
                  TreeRecord.fromJson(Map<String, dynamic>.from(item as Map)));
            } catch (error) {
              debugPrint('Skipping invalid tree record: $error');
            }
          }
          trees
            ..clear()
            ..addAll(restored);
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to load tree records: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => loaded = true);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'trees_v1', jsonEncode(trees.map((t) => t.toJson()).toList()));
  }

  void _add(TreeRecord tree) {
    setState(() {
      trees.insert(0, tree);
      selected = 1;
    });
    _save();
  }

  void _delete(TreeRecord tree) {
    setState(() => trees.removeWhere((t) => t.id == tree.id));
    _save();
  }

  void _toggle(TreeRecord tree) {
    final index = trees.indexWhere((t) => t.id == tree.id);
    if (index < 0) return;
    setState(() => trees[index] = tree.copyWith(needsCare: !tree.needsCare));
    _save();
  }

  void _openAdd() => Navigator.push(context,
      MaterialPageRoute<void>(builder: (_) => AddTreeScreen(onSave: _add)));
  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(
          trees: trees,
          onAdd: _openAdd,
          onShowTrees: () => setState(() => selected = 1)),
      TreeDiary(
          trees: trees, onAdd: _openAdd, onDelete: _delete, onToggle: _toggle),
      Insights(trees: trees),
      const AboutScreen(),
    ];
    return Scaffold(
        body: SafeArea(
            child: !loaded
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(index: selected, children: pages)),
        floatingActionButton: selected < 2
            ? FloatingActionButton(
                onPressed: _openAdd,
                backgroundColor: forest,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.add))
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: NavigationBar(
            height: 75,
            selectedIndex: selected,
            indicatorColor: const Color(0xFFDDEBD7),
            backgroundColor: Colors.white,
            onDestinationSelected: (i) => setState(() => selected = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.park_outlined),
                  selectedIcon: Icon(Icons.park),
                  label: 'My Trees'),
              NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Insights'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'About'),
            ]));
  }
}

class Dashboard extends StatelessWidget {
  final List<TreeRecord> trees;
  final VoidCallback onAdd, onShowTrees;
  const Dashboard(
      {super.key,
      required this.trees,
      required this.onAdd,
      required this.onShowTrees});
  @override
  Widget build(BuildContext context) {
    final care = trees.where((t) => t.needsCare).length;
    return ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
        children: [
          Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Hello, Green Guardian 🌿',
                      style: TextStyle(color: forest, fontSize: 14)),
                  SizedBox(height: 5),
                  Text('Grow a greener\ntomorrow.',
                      style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          height: 1.13))
                ])),
            CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFDDEBD7),
                child: const Icon(Icons.eco, color: forest, size: 29))
          ]),
          const SizedBox(height: 24),
          Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF225C3B), Color(0xFF629465)]),
                  borderRadius: BorderRadius.circular(27)),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('YOUR GREEN IMPACT',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('${trees.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 53,
                              fontWeight: FontWeight.w800)),
                      const Text('Trees recorded',
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                      const SizedBox(height: 16),
                      const Text('Every tree tells a story.',
                          style: TextStyle(color: Colors.white70, fontSize: 12))
                    ])),
                const Icon(Icons.forest, color: Color(0xFFD2E9AF), size: 108)
              ])),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: _Stat(
                    icon: Icons.spa,
                    value: '${trees.length - care}',
                    label: 'Doing well')),
            const SizedBox(width: 12),
            Expanded(
                child: _Stat(
                    icon: Icons.water_drop_outlined,
                    value: '$care',
                    label: 'Needs care'))
          ]),
          const SizedBox(height: 26),
          const Text('Quick actions',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _Action(
                    icon: Icons.add_circle_outline,
                    title: 'Plant a tree',
                    onTap: onAdd)),
            const SizedBox(width: 12),
            Expanded(
                child: _Action(
                    icon: Icons.menu_book_outlined,
                    title: 'View diary',
                    onTap: onShowTrees))
          ]),
          const SizedBox(height: 27),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent plantations',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            TextButton(onPressed: onShowTrees, child: const Text('View all'))
          ]),
          if (trees.isEmpty)
            const EmptyTrees()
          else
            ...trees.take(3).map((t) => TreeTile(tree: t, onTap: onShowTrees)),
        ]);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _Stat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: forest, size: 27),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black54))
          ])));
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
      color: const Color(0xFFE6EEDC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(children: [
                Icon(icon, color: forest, size: 29),
                const SizedBox(height: 9),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
              ]))));
}

class EmptyTrees extends StatelessWidget {
  const EmptyTrees({super.key});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            const Icon(Icons.yard_outlined, size: 58, color: sage),
            const SizedBox(height: 10),
            const Text('Your green journey starts here',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Add your first tree to begin your diary.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54))
          ])));
}

class TreeTile extends StatelessWidget {
  final TreeRecord tree;
  final VoidCallback onTap;
  const TreeTile({super.key, required this.tree, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(11),
          leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: const Color(0xFFE6EEDC),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.park, color: forest, size: 32)),
          title: Text(tree.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              tree.location.isEmpty ? 'Location not specified' : tree.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          trailing: Icon(tree.needsCare ? Icons.water_drop : Icons.check_circle,
              color: tree.needsCare ? Colors.orange : forest)));
}

class TreeDiary extends StatefulWidget {
  final List<TreeRecord> trees;
  final VoidCallback onAdd;
  final void Function(TreeRecord) onDelete, onToggle;
  const TreeDiary(
      {super.key,
      required this.trees,
      required this.onAdd,
      required this.onDelete,
      required this.onToggle});
  @override
  State<TreeDiary> createState() => _TreeDiaryState();
}

class _TreeDiaryState extends State<TreeDiary> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.trees
        .where((t) => '${t.name} ${t.species} ${t.location}'
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 110),
        children: [
          const Text('My Trees',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Every tree has a story worth keeping.',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search your trees...')),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            const EmptyTrees()
          else
            ...filtered.map((tree) => TreeTile(
                tree: tree,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => TreeDetails(
                            tree: tree,
                            onDelete: () {
                              widget.onDelete(tree);
                              Navigator.pop(context);
                            },
                            onToggle: () {
                              widget.onToggle(tree);
                              Navigator.pop(context);
                            }))))),
        ]);
  }
}

class TreeDetails extends StatelessWidget {
  final TreeRecord tree;
  final VoidCallback onDelete, onToggle;
  const TreeDetails(
      {super.key,
      required this.tree,
      required this.onDelete,
      required this.onToggle});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Tree details')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        Container(
            height: 170,
            decoration: BoxDecoration(
                color: const Color(0xFFE0EBD4),
                borderRadius: BorderRadius.circular(25)),
            child: const Icon(Icons.park, size: 110, color: forest)),
        const SizedBox(height: 22),
        Text(tree.name,
            style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
        const SizedBox(height: 15),
        _Detail(
            'Species', tree.species.isEmpty ? 'Not specified' : tree.species),
        _Detail('Location',
            tree.location.isEmpty ? 'Not specified' : tree.location),
        _Detail('Planted on',
            '${tree.planted.day}/${tree.planted.month}/${tree.planted.year}'),
        _Detail(
            'Height', tree.height == 0 ? 'Not recorded' : '${tree.height} cm'),
        _Detail('Care status', tree.needsCare ? 'Needs care' : 'Doing well'),
        _Detail('Notes', tree.notes.isEmpty ? 'No notes yet' : tree.notes),
        const SizedBox(height: 18),
        FilledButton.icon(
            onPressed: onToggle,
            icon: const Icon(Icons.water_drop_outlined),
            label: Text(
                tree.needsCare ? 'Mark as cared for' : 'Mark as needing care')),
        TextButton.icon(
            onPressed: () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                        title: const Text('Delete tree?'),
                        content: const Text(
                            'This record will be permanently deleted.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onDelete();
                              },
                              child: const Text('Delete'))
                        ])),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete record',
                style: TextStyle(color: Colors.red))),
      ]));
}

class _Detail extends StatelessWidget {
  final String label, value;
  const _Detail(this.label, this.value);
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(17),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          ])));
}

class AddTreeScreen extends StatefulWidget {
  final void Function(TreeRecord) onSave;
  const AddTreeScreen({super.key, required this.onSave});
  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      species = TextEditingController(),
      location = TextEditingController(),
      notes = TextEditingController(),
      height = TextEditingController();
  DateTime planted = DateTime.now();
  bool needsCare = false;
  @override
  void dispose() {
    name.dispose();
    species.dispose();
    location.dispose();
    notes.dispose();
    height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add a Tree')),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(22), children: [
            Container(
                height: 145,
                decoration: BoxDecoration(
                    color: const Color(0xFFE0EBD4),
                    borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.nature, size: 88, color: forest)),
            const SizedBox(height: 20),
            TextFormField(
                controller: name,
                decoration: const InputDecoration(
                    labelText: 'Tree name *',
                    prefixIcon: Icon(Icons.eco_outlined)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a tree name' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: species,
                decoration: const InputDecoration(
                    labelText: 'Species',
                    prefixIcon: Icon(Icons.spa_outlined))),
            const SizedBox(height: 12),
            TextFormField(
                controller: location,
                decoration: const InputDecoration(
                    labelText: 'Plantation location',
                    prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            Card(
                child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: forest),
                    title: const Text('Plantation date'),
                    subtitle:
                        Text('${planted.day}/${planted.month}/${planted.year}'),
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: planted,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now());
                      if (d != null) setState(() => planted = d);
                    })),
            const SizedBox(height: 12),
            TextFormField(
                controller: height,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final h = double.tryParse(v);
                  return h == null || h < 0 ? 'Enter a valid height' : null;
                }),
            const SizedBox(height: 12),
            TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes', prefixIcon: Icon(Icons.notes))),
            SwitchListTile(
                title: const Text('Needs care'),
                value: needsCare,
                onChanged: (v) => setState(() => needsCare = v)),
            const SizedBox(height: 20),
            SizedBox(
                height: 54,
                child: FilledButton.icon(
                    onPressed: () {
                      if (!(form.currentState?.validate() ?? false)) return;
                      widget.onSave(TreeRecord(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: name.text.trim(),
                          species: species.text.trim(),
                          location: location.text.trim(),
                          notes: notes.text.trim(),
                          planted: planted,
                          height: double.tryParse(height.text) ?? 0,
                          needsCare: needsCare));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Save tree'))),
            const SizedBox(height: 32),
          ])));
}

class Insights extends StatelessWidget {
  final List<TreeRecord> trees;
  const Insights({super.key, required this.trees});
  @override
  Widget build(BuildContext context) {
    final care = trees.where((t) => t.needsCare).length;
    final locations = trees
        .map((t) => t.location.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
    return ListView(padding: const EdgeInsets.all(22), children: [
      const Text('Your Impact',
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Small steps, greener future.',
          style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 22),
      _Stat(
          icon: Icons.forest,
          value: '${trees.length}',
          label: 'Trees recorded'),
      _Stat(
          icon: Icons.check_circle_outline,
          value: '${trees.length - care}',
          label: 'Doing well'),
      _Stat(
          icon: Icons.water_drop_outlined, value: '$care', label: 'Need care'),
      _Stat(
          icon: Icons.place_outlined,
          value: '$locations',
          label: 'Recorded locations'),
      const SizedBox(height: 20),
      const Text('SDG 15 · Life on Land',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('GreenRoots helps you document tree planting '
          'and follow up on tree care. These counts are based on your own diary entries, '
          'not independently verified environmental impact.'),
    ]);
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: const [
        SizedBox(height: 28),
        Center(child: Icon(Icons.eco, size: 86, color: forest)),
        SizedBox(height: 15),
        Center(
            child: Text('GreenRoots',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800))),
        SizedBox(height: 6),
        Center(child: Text('Tree Plantation Diary')),
        SizedBox(height: 28),
        Card(
            child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                    'Plant today for a greener tomorrow. Record the trees you plant, '
                    'track their care status, and reflect on your contribution to SDG 15: Life on Land.'))),
        SizedBox(height: 15),
        Center(
            child: Text('Flutter SDG Assignment · 24PA1A05H2',
                style: TextStyle(color: Colors.black54))),
      ]);
}
