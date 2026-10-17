import 'package:flutter/material.dart';
import '../theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(22, 38, 22, 110),
        children: [
          Center(
              child: Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
                color: Color(0xFFE2EEDB), shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, size: 64, color: forest),
          )),
          const SizedBox(height: 20),
          const Center(
              child: Text('GreenRoots',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800))),
          const SizedBox(height: 6),
          const Center(
              child: Text('Your personal tree plantation diary',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14))),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grow something meaningful',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                SizedBox(height: 12),
                Text(
                    'GreenRoots helps you remember every tree you plant. '
                    'Save plantation details, check which trees need care, '
                    'and watch your green journey grow over time.',
                    style: TextStyle(height: 1.55, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFE2EEDB),
                borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              Icon(Icons.public, color: forest, size: 31),
              SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspired by SDG 15',
                      style: TextStyle(
                          color: forest,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Life on Land · Care for nature',
                      style: TextStyle(color: forest, fontSize: 13)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 30),
          const Center(
              child: Text('Plant today. Grow tomorrow.',
                  style: TextStyle(
                      color: forest,
                      fontSize: 15,
                      fontWeight: FontWeight.w700))),
        ],
      );
}
