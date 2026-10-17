import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenroots/app.dart';
import 'package:greenroots/models/tree_record.dart';
import 'package:greenroots/services/tree_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('greenroots/tree_storage');
  String? savedJson;

  setUp(() {
    savedJson = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'readTrees':
          return savedJson;
        case 'writeTrees':
          savedJson = (call.arguments as Map)['value'] as String;
          return true;
        default:
          throw PlatformException(code: 'NOT_IMPLEMENTED');
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('GreenRoots application loads', (tester) async {
    await tester.pumpWidget(const GreenRootsApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('Tree diary survives save and reload', () async {
    final storage = TreeStorage();
    final tree = TreeRecord(
      id: 'test-1',
      name: 'Neem',
      species: 'Azadirachta indica',
      location: 'Garden',
      notes: 'Healthy',
      planted: DateTime(2026, 10, 17),
      height: 1.5,
      needsCare: true,
    );
    await storage.save([tree]);
    final restored = await storage.load();
    expect(restored, hasLength(1));
    expect(restored.first.name, 'Neem');
    expect(restored.first.needsCare, isTrue);
  });

  test('Invalid stored JSON is not silently overwritten', () async {
    savedJson = '{invalid';
    final storage = TreeStorage();
    await expectLater(storage.load(), throwsFormatException);
    expect(savedJson, '{invalid');
  });
}
