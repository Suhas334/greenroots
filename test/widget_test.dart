import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenroots/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GreenRoots application loads', (tester) async {
    await tester.pumpWidget(const GreenRootsApp());

    // Allow local storage initialization to complete.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check that the application is displayed.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Make every tree\ncount.'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Trees'), findsOneWidget);
  });
}
