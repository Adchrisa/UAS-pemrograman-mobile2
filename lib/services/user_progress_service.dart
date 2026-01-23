import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sync user-specific progress (bookmarks & read articles) with Supabase.
/// Falls back to local SharedPreferences when user is not logged in or offline.
class UserProgressService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static String _userIdOrGuest() {
    final user = _supabase.auth.currentUser;
    return user?.id ?? 'guest';
  }

  static String _localKey(String base) => '${base}_${_userIdOrGuest()}';

  // Local cache helpers ------------------------------------------------------
  static Future<Set<String>> _readLocalSet(String key) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(key) ?? const <String>[];
    return list.toSet();
  }

  static Future<void> _writeLocalSet(String key, Set<String> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(key, data.toList());
  }

  // Supabase table: user_progress (user_id text pk, bookmarks text[], read_articles text[])
  static const _table = 'user_progress';

  static Future<Map<String, dynamic>?> _fetchRow(String userId) async {
    final rows = await _supabase
        .from(_table)
        .select('user_id, bookmarks, read_articles')
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static Future<void> _ensureRow(String userId) async {
    final exists = await _fetchRow(userId);
    if (exists != null) return;
    await _supabase.from(_table).insert({
      'user_id': userId,
      'bookmarks': <String>[],
      'read_articles': <String>[],
    });
  }

  static Future<Set<String>> getBookmarks() async {
    final userId = _userIdOrGuest();
    final localKey = _localKey('ecohelper_bookmarks');

    // Guest: local only
    if (userId == 'guest') {
      return _readLocalSet(localKey);
    }

    try {
      await _ensureRow(userId);
      final row = await _fetchRow(userId);
      final list = (row?['bookmarks'] as List?)?.cast<String>() ?? <String>[];
      final set = list.toSet();
      // Cache locally for offline use
      await _writeLocalSet(localKey, set);
      return set;
    } catch (_) {
      // Offline fallback
      return _readLocalSet(localKey);
    }
  }

  static Future<void> setBookmarks(Set<String> data) async {
    final userId = _userIdOrGuest();
    final localKey = _localKey('ecohelper_bookmarks');
    await _writeLocalSet(localKey, data);

    if (userId == 'guest') return; // only local for guest

    try {
      await _ensureRow(userId);
      await _supabase
          .from(_table)
          .update({'bookmarks': data.toList()})
          .eq('user_id', userId);
    } catch (_) {
      // swallow; local cache already updated
    }
  }

  static Future<Set<String>> getReadArticles() async {
    final userId = _userIdOrGuest();
    final localKey = _localKey('ecohelper_read_articles');

    if (userId == 'guest') {
      return _readLocalSet(localKey);
    }

    try {
      await _ensureRow(userId);
      final row = await _fetchRow(userId);
      final list = (row?['read_articles'] as List?)?.cast<String>() ?? <String>[];
      final set = list.toSet();
      await _writeLocalSet(localKey, set);
      return set;
    } catch (_) {
      return _readLocalSet(localKey);
    }
  }

  static Future<void> setReadArticles(Set<String> data) async {
    final userId = _userIdOrGuest();
    final localKey = _localKey('ecohelper_read_articles');
    await _writeLocalSet(localKey, data);

    if (userId == 'guest') return;

    try {
      await _ensureRow(userId);
      await _supabase
          .from(_table)
          .update({'read_articles': data.toList()})
          .eq('user_id', userId);
    } catch (_) {
      // keep local cache if offline
    }
  }
}
