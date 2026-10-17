import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tree_record.dart';

class TreeStorage {
  static const String key = 'trees_v1';

  Future<List<TreeRecord>> load() async {
    late final SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      debugPrint('SharedPreferences initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }

    String? raw;

    try {
      raw = prefs.getString(key);
    } catch (error, stackTrace) {
      debugPrint('Reading tree storage failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }

    if (raw == null || raw.isEmpty) {
      return <TreeRecord>[];
    }

    late final dynamic decoded;

    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException(
        'Saved tree data contains invalid JSON: ${error.message}',
      );
    }

    if (decoded is! List) {
      throw const FormatException(
        'Saved tree data is not a JSON list.',
      );
    }

    final records = <TreeRecord>[];

    for (var index = 0; index < decoded.length; index++) {
      try {
        final item = decoded[index];

        if (item is! Map) {
          throw const FormatException(
            'Tree record is not a JSON object.',
          );
        }

        final tree = TreeRecord.fromJson(
          Map<String, dynamic>.from(item),
        );

        records.add(tree);
      } catch (error) {
        debugPrint(
          'Skipping invalid tree record at index $index: $error',
        );
      }
    }

    return records;
  }

  Future<void> save(List<TreeRecord> trees) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      trees.map((tree) => tree.toJson()).toList(),
    );

    final success = await prefs.setString(key, encoded);

    if (!success) {
      throw StateError(
        'SharedPreferences could not save tree records.',
      );
    }
  }
}
