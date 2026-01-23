import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

  static const _key = 'eco_dark_mode';

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    notifier.value = sp.getBool(_key) ?? false;
  }

  static Future<void> setDark(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, v);
    notifier.value = v;
  }
}
