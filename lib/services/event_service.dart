import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  static const _key = 'ecohelper_joined_events';

  static Future<List<String>> getJoined() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? <String>[];
  }

  static Future<void> toggleJoin(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    final set = list.toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await sp.setStringList(_key, set.toList());
  }
}
