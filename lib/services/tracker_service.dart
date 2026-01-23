import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerService {
  static final ValueNotifier<Map<String, bool>> notifier = ValueNotifier({
    'not_use_plastic': false,
    'save_water': false,
    'save_energy': false,
  });

  static const _key = 'eco_tracker_state';
  static const _historyKey = 'eco_tracker_history';

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final today = _getToday();
    
    // Check if it's a new day, reset checkboxes if so
    final lastDate = sp.getString('last_check_date') ?? '';
    if (lastDate != today) {
      // Save yesterday's data to history before reset
      if (lastDate.isNotEmpty) {
        await _saveToHistory(sp, lastDate);
      }
      // Reset for new day
      await _resetDaily(sp);
      await sp.setString('last_check_date', today);
    }
    
    // Load today's state
    final map = <String, bool>{};
    final keys = notifier.value.keys;
    for (final k in keys) {
      map[k] = sp.getBool('$_key:$k') ?? false;
    }
    notifier.value = map;
  }

  static Future<void> toggle(String key) async {
    final sp = await SharedPreferences.getInstance();
    final current = notifier.value[key] ?? false;
    notifier.value = {...notifier.value, key: !current};
    await sp.setBool('$_key:$key', !current);
    
    // Save to today's history
    final today = _getToday();
    await _saveToHistory(sp, today);
  }

  static bool getValue(String key) => notifier.value[key] ?? false;

  static String _getToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void> _resetDaily(SharedPreferences sp) async {
    final keys = notifier.value.keys;
    for (final k in keys) {
      await sp.setBool('$_key:$k', false);
    }
    notifier.value = {
      'not_use_plastic': false,
      'save_water': false,
      'save_energy': false,
    };
  }

  static Future<void> _saveToHistory(SharedPreferences sp, String date) async {
    final allComplete = notifier.value.values.every((v) => v);
    if (allComplete) {
      final history = sp.getStringList(_historyKey) ?? [];
      if (!history.contains(date)) {
        history.add(date);
        await sp.setStringList(_historyKey, history);
      }
    }
  }

  // Get streak (consecutive days)
  static Future<int> getStreak() async {
    final sp = await SharedPreferences.getInstance();
    final history = sp.getStringList(_historyKey) ?? [];
    if (history.isEmpty) return 0;

    history.sort((a, b) => b.compareTo(a)); // Sort descending
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    for (int i = 0; i < history.length; i++) {
      final dateStr = history[i];
      final historyDate = DateTime.parse(dateStr);
      final expectedDate = checkDate.subtract(Duration(days: i));
      
      // Check if date matches expected consecutive date
      if (historyDate.year == expectedDate.year &&
          historyDate.month == expectedDate.month &&
          historyDate.day == expectedDate.day) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Get completion rate for last 7 days
  static Future<double> getLast7DaysRate() async {
    final sp = await SharedPreferences.getInstance();
    final history = sp.getStringList(_historyKey) ?? [];
    
    int completedDays = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (history.contains(dateStr)) {
        completedDays++;
      }
    }
    
    return completedDays / 7;
  }

  // Get total successful days this month
  static Future<int> getMonthlyTotal() async {
    final sp = await SharedPreferences.getInstance();
    final history = sp.getStringList(_historyKey) ?? [];
    final now = DateTime.now();
    
    int count = 0;
    for (final dateStr in history) {
      final date = DateTime.parse(dateStr);
      if (date.year == now.year && date.month == now.month) {
        count++;
      }
    }
    
    return count;
  }

  // Get all history dates
  static Future<List<String>> getHistory() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_historyKey) ?? [];
  }
}
