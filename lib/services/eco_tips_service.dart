import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EcoTipsService {
  static const _key = 'ecohelper_completed_tips';

  // Notifier for listeners to rebuild when completed tips change
  static final ValueNotifier<Set<String>> notifier = ValueNotifier(<String>{});

  static Future<Set<String>> _readSet() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    final set = list.toSet();
    notifier.value = set;
    return set;
  }

  static Future<bool> isCompleted(String id) async {
    final set = await _readSet();
    return set.contains(id);
  }

  static Future<void> toggle(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    final set = list.toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await sp.setStringList(_key, set.toList());
    notifier.value = set;
  }

  static Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    notifier.value = <String>{};
  }

  static Future<List<String>> getAll() async {
    final set = await _readSet();
    return set.toList();
  }
}
