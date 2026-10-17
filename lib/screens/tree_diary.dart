import 'package:flutter/material.dart';
import '../models/tree_record.dart';
import '../widgets/common_widgets.dart';
import 'tree_details.dart';

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
