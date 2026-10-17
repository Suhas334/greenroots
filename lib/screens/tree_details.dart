import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/tree_record.dart';

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
