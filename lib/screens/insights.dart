import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/tree_record.dart';
import '../widgets/common_widgets.dart';

class Insights extends StatelessWidget {
  final List<TreeRecord> trees;
  const Insights({super.key, required this.trees});

  @override
  Widget build(BuildContext context) {
    final care = trees.where((t) => t.needsCare).length;
    final locations = trees
        .map((t) => t.location.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
    final total = trees.length;
    final healthy = total - care;
    final progress = total == 0 ? 0.0 : healthy / total;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        const Text('Your Impact',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('See how your green journey is growing.',
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
              color: const Color(0xFFE2EEDB),
              borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.eco_rounded, color: forest),
                SizedBox(width: 9),
                Text('Tree care overview',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
              const SizedBox(height: 13),
              Text(
                  total == 0
                      ? 'Add your first tree to get started.'
                      : '$healthy of $total trees are doing well',
                  style: const TextStyle(color: forest, fontSize: 14)),
              const SizedBox(height: 13),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 11,
                      backgroundColor: Colors.white,
                      color: forest)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(
              child: StatCard(
                  icon: Icons.forest_rounded,
                  value: '$total',
                  label: 'Trees recorded')),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  icon: Icons.check_circle_outline,
                  value: '$healthy',
                  label: 'Doing well')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: StatCard(
                  icon: Icons.water_drop_outlined,
                  value: '$care',
                  label: 'Needs care')),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  icon: Icons.place_outlined,
                  value: '$locations',
                  label: 'Locations')),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.public, color: forest),
                SizedBox(width: 9),
                Text('Life on Land · SDG 15',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
              SizedBox(height: 10),
              Text(
                  'Every planted tree matters. Keep a record of your '
                  'plantations and return regularly to check their care needs.',
                  style: TextStyle(color: Colors.black87, height: 1.5)),
              SizedBox(height: 8),
              Text(
                  'Statistics reflect your diary entries, not independently '
                  'verified environmental impact.',
                  style: TextStyle(
                      color: Colors.black54, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
