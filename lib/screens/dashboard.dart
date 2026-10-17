import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/tree_record.dart';
import '../widgets/common_widgets.dart';

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
    final healthy = trees.length - care;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      children: [
        Row(children: [
          const Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WELCOME TO GREENROOTS',
                  style: TextStyle(
                      color: forest,
                      letterSpacing: 1.4,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('Make every tree\ncount.',
                  style: TextStyle(
                      fontSize: 29, height: 1.12, fontWeight: FontWeight.w800)),
            ],
          )),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
                color: Color(0xFFE0EDD8), shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, color: forest, size: 29),
          ),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF135437), Color(0xFF4D9568)]),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.forest_rounded, color: Color(0xFFD9F0C5), size: 23),
              SizedBox(width: 8),
              Text('YOUR GREEN IMPACT',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
            ]),
            const SizedBox(height: 18),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${trees.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 57,
                      height: 1,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 15),
              const Expanded(
                  child: Text('trees in your\nplantation diary',
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.3))),
              const Icon(Icons.park_rounded,
                  color: Color(0xFFC9E8B4), size: 67),
            ]),
            const SizedBox(height: 19),
            const Text('A greener future starts with one tree.',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: StatCard(
                  icon: Icons.check_circle_outline,
                  value: '$healthy',
                  label: 'Doing well')),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  icon: Icons.water_drop_outlined,
                  value: '$care',
                  label: 'Needs care')),
        ]),
        const SizedBox(height: 24),
        const Text('Quick actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: ActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Plant a tree',
                  onTap: onAdd)),
          const SizedBox(width: 12),
          Expanded(
              child: ActionCard(
                  icon: Icons.menu_book_outlined,
                  title: 'View diary',
                  onTap: onShowTrees)),
        ]),
        const SizedBox(height: 26),
        Row(children: [
          const Expanded(
              child: Text('Recent plantations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
          TextButton(onPressed: onShowTrees, child: const Text('View all')),
        ]),
        const SizedBox(height: 5),
        if (trees.isEmpty)
          const EmptyTrees()
        else
          ...trees.take(3).map((t) => TreeTile(tree: t, onTap: onShowTrees)),
      ],
    );
  }
}
