import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_progress_service.dart';

class BookmarkService {
  static String _key() {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    return 'ecohelper_bookmarks_$userId';
  }

  // Notifier for listeners to rebuild when bookmarks change
  static final ValueNotifier<Set<String>> notifier = ValueNotifier(<String>{});

  static Future<Set<String>> _readSet() async {
    final key = _key();
    final sp = await SharedPreferences.getInstance();
    final cached = sp.getStringList(key) ?? <String>[];

    // If logged in, sync with Supabase; else use cache.
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final remote = await UserProgressService.getBookmarks();
      notifier.value = remote;
      return remote;
    }

    final set = cached.toSet();
    notifier.value = set;
    return set;
  }

  static Future<bool> isBookmarked(String id) async {
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
    // Sync to Supabase if logged in
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await UserProgressService.setBookmarks(set);
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
      await UserProgressService.setBookmarks(<String>{});
    }
  }

  static Future<List<String>> getAll() async {
    final set = await _readSet();
    return set.toList();
  }

  /// Clear bookmarks if a developer requested a one-time reset flag.
  /// This checks for a boolean key `eco_reset_bookmarks_request` in SharedPreferences.
  /// If present and true, it clears bookmarks and resets the request flag.
  /// Returns true if a reset was requested and executed.
  static Future<bool> resetIfRequested() async {
    final sp = await SharedPreferences.getInstance();
    final req = sp.getBool('eco_reset_bookmarks_request') ?? false;
    if (req) {
      await sp.remove(_key());
      notifier.value = <String>{};
      await sp.setBool('eco_reset_bookmarks_request', false);
      return true;
    }
    return false;
  }
}
