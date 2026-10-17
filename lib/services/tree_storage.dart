import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/tree_record.dart';

/// Uses Android's native SharedPreferences directly to avoid a broken
/// shared_preferences plugin binary interface on some release builds.
/// The native bridge reads the original `flutter.trees_v1` preference.
class TreeStorage {
  static const String key = 'trees_v1';
  static const MethodChannel _channel = MethodChannel('greenroots/tree_storage');

  Future<List<TreeRecord>> load() async {
    final raw = await _channel.invokeMethod<String>('readTrees');
    if (raw == null || raw.isEmpty) return <TreeRecord>[];

    final dynamic data;
    try {
      data = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('Saved tree diary JSON is damaged. Existing data was not changed.');
    }
    if (data is! List) {
      throw const FormatException('Saved tree diary is not a list. Existing data was not changed.');
    }

    final records = <TreeRecord>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) {
        throw FormatException('Tree record $i is invalid. Existing data was not changed.');
      }
      try {
        records.add(TreeRecord.fromJson(Map<String, dynamic>.from(item)));
      } catch (error) {
        throw FormatException('Tree record $i could not be read: $error. Existing data was not changed.');
      }
    }
    return records;
  }

  Future<void> save(List<TreeRecord> trees) async {
    final json = jsonEncode(trees.map((tree) => tree.toJson()).toList());
    final ok = await _channel.invokeMethod<bool>('writeTrees', {'value': json});
    if (ok != true) {
      throw StateError('Android could not save tree records.');
    }
  }
}
