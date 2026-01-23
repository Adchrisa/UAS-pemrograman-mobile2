import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _localKeyName = 'eco_name';

  // Load user display name from Supabase (if logged in) or local cache
  static Future<String> loadDisplayName() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('user_profile')
            .select('display_name')
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null && data['display_name'] != null) {
          final name = data['display_name'] as String;
          await _cacheName(name);
          return name;
        }
      } catch (_) {
        // fallback to local
      }
    }

    // Local cache
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localKeyName) ?? 'Pengguna EcoHelper';
  }

  // Save user display name to Supabase and local cache
  static Future<void> saveDisplayName(String name) async {
    // Always cache locally
    await _cacheName(name);

    // If logged in, push to Supabase
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_profile').upsert({
          'user_id': user.id,
          'display_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore offline errors; cache already updated
      }
    }
  }

  static Future<void> _cacheName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKeyName, name);
  }
}
