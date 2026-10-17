import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_record.dart';

/// Keeps the original key so existing installations retain their records.
class TreeStorage {
  static const key = 'trees_v1';

  Future<List<TreeRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw);
    if (data is! List) throw const FormatException('Invalid diary format');
    final records = <TreeRecord>[];
    for (final item in data) {
      try {
        records
            .add(TreeRecord.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (_) {
        // Keep valid records even if an individual entry is damaged.
      }
    }
    return records;
  }

  Future<void> save(List<TreeRecord> trees) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
        key, jsonEncode(trees.map((t) => t.toJson()).toList()));
    if (!ok) throw StateError('Could not persist tree records');
  }
}
