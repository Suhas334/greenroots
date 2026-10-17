import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenroots/main.dart';

void main() {
  testWidgets('GreenRoots application loads', (tester) async {
    await tester.pumpWidget(const GreenRootsApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
