import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_progress_service.dart';

class ReadArticlesService {
  static String _key() {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    return 'ecohelper_read_articles_$userId';
  }

  // Notifier for listeners to rebuild when read articles change
  static final ValueNotifier<Set<String>> notifier = ValueNotifier(<String>{});

  static Future<Set<String>> _readSet() async {
    final key = _key();
    final sp = await SharedPreferences.getInstance();
    final cached = sp.getStringList(key) ?? <String>[];

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final remote = await UserProgressService.getReadArticles();
      notifier.value = remote;
      return remote;
    }

    final set = cached.toSet();
    notifier.value = set;
    return set;
  }

  static Future<bool> isRead(String id) async {
    final set = await _readSet();
    return set.contains(id);
  }

  static Future<void> toggle(String id) async {
    final key = _key();
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(key) ?? <String>[];
    final set = list.toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await sp.setStringList(key, set.toList());
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await UserProgressService.setReadArticles(set);
    }
    notifier.value = set;
  }

  static Future<void> clearAll() async {
    final key = _key();
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
    notifier.value = <String>{};
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await UserProgressService.setReadArticles(<String>{});
    }
  }

  static Future<List<String>> getAll() async {
    final set = await _readSet();
    return set.toList();
  }
}
