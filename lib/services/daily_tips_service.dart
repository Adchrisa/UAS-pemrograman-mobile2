import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tip_model.dart';

class DailyTipsService {
  static String _getUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? 'guest';
  }

  static String get _keyCompletedTips => 'eco_completed_tips_${_getUserId()}';
  static String get _keyActiveChallenges => 'eco_active_challenges_${_getUserId()}';

  static final ValueNotifier<Set<String>> completedTipsNotifier = ValueNotifier(<String>{});
  static final ValueNotifier<List<ChallengeProgress>> activeChallengesNotifier = ValueNotifier([]);

  // Initialize service
  static Future<void> init() async {
    await _loadCompletedTips();
    await _loadActiveChallenges();
  }

  // Load completed tips
  static Future<void> _loadCompletedTips() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedTips) ?? [];
    completedTipsNotifier.value = list.toSet();
  }

  // Save completed tip
  static Future<void> completeTip(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedTips) ?? [];
    final set = list.toSet()..add(tipId);
    await prefs.setStringList(_keyCompletedTips, set.toList());
    completedTipsNotifier.value = set;
  }

  // Check if tip is completed
  static Future<bool> isTipCompleted(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedTips) ?? [];
    return list.contains(tipId);
  }

  // Load active challenges
  static Future<void> _loadActiveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyActiveChallenges) ?? [];
    final challenges = jsonList
        .map((json) => ChallengeProgress.fromJson(jsonDecode(json)))
        .toList();
    activeChallengesNotifier.value = challenges;
  }

  // Start a challenge
  static Future<void> startChallenge(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyActiveChallenges) ?? [];
    
    final progress = ChallengeProgress(
      challengeId: challengeId,
      startDate: DateTime.now(),
    );
    
    jsonList.add(jsonEncode(progress.toJson()));
    await prefs.setStringList(_keyActiveChallenges, jsonList);
    await _loadActiveChallenges();
  }

  // Complete a challenge
  static Future<void> completeChallenge(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyActiveChallenges) ?? [];
    
    final challenges = jsonList
        .map((json) => ChallengeProgress.fromJson(jsonDecode(json)))
        .toList();
    
    final updatedChallenges = challenges.map((c) {
      if (c.challengeId == challengeId) {
        return ChallengeProgress(
          challengeId: c.challengeId,
          startDate: c.startDate,
          completedDate: DateTime.now(),
          isCompleted: true,
          progress: 100,
        );
      }
      return c;
    }).toList();
    
    final updatedJsonList = updatedChallenges.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyActiveChallenges, updatedJsonList);
    await _loadActiveChallenges();
  }

  // Get daily tip (rotates based on day)
  static DailyTip getDailyTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tips = _allTips;
    final index = dayOfYear % tips.length;
    return tips[index];
  }

  // Get available challenges
  static List<Challenge> getAvailableChallenges() {
    return _allChallenges;
  }

  // All tips database
  static final List<DailyTip> _allTips = [
    DailyTip(
      id: 'tip1',
      title: 'Matikan Lampu',
      description: 'Matikan lampu saat meninggalkan ruangan untuk hemat energi',
      category: 'energy',
      points: 10,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip2',
      title: 'Bawa Tas Belanja',
      description: 'Hindari kantong plastik dengan membawa tas belanja sendiri',
      category: 'waste',
      points: 10,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip3',
      title: 'Tutup Keran',
      description: 'Pastikan keran tertutup rapat saat tidak digunakan',
      category: 'water',
      points: 10,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip4',
      title: 'Gunakan Transportasi Umum',
      description: 'Kurangi emisi karbon dengan naik bus atau kereta',
      category: 'transport',
      points: 15,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip5',
      title: 'Daur Ulang Kertas',
      description: 'Pisahkan kertas bekas untuk didaur ulang',
      category: 'waste',
      points: 10,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip6',
      title: 'Cabut Charger',
      description: 'Cabut charger yang tidak digunakan untuk hemat listrik',
      category: 'energy',
      points: 10,
      date: DateTime.now(),
    ),
    DailyTip(
      id: 'tip7',
      title: 'Botol Minum Sendiri',
      description: 'Bawa botol minum untuk kurangi sampah plastik',
      category: 'waste',
      points: 10,
      date: DateTime.now(),
    ),
  ];

  // All challenges database
  static final List<Challenge> _allChallenges = [
    Challenge(
      id: 'ch1',
      title: 'Zero Waste Day',
      description: 'Habiskan hari tanpa menghasilkan sampah plastik',
      difficulty: 'easy',
      points: 50,
      durationDays: 1,
      icon: '♻️',
    ),
    Challenge(
      id: 'ch2',
      title: 'Car-Free Week',
      description: 'Tidak menggunakan kendaraan pribadi selama seminggu',
      difficulty: 'hard',
      points: 200,
      durationDays: 7,
      icon: '🚶',
    ),
    Challenge(
      id: 'ch3',
      title: 'Energy Saver',
      description: 'Kurangi konsumsi listrik 30% hari ini',
      difficulty: 'medium',
      points: 75,
      durationDays: 1,
      icon: '⚡',
    ),
    Challenge(
      id: 'ch4',
      title: 'Water Warrior',
      description: 'Hemat air dengan mandi maksimal 5 menit',
      difficulty: 'easy',
      points: 30,
      durationDays: 1,
      icon: '💧',
    ),
    Challenge(
      id: 'ch5',
      title: 'Eco Commuter',
      description: 'Gunakan sepeda atau jalan kaki untuk semua perjalanan',
      difficulty: 'medium',
      points: 100,
      durationDays: 3,
      icon: '🚴',
    ),
    Challenge(
      id: 'ch6',
      title: 'Vegetarian Day',
      description: 'Tidak konsumsi daging selama sehari penuh',
      difficulty: 'easy',
      points: 40,
      durationDays: 1,
      icon: '🥗',
    ),
    Challenge(
      id: 'ch7',
      title: 'Reusable Champion',
      description: 'Gunakan produk reusable untuk semua kebutuhan (tumbler, tas, alat makan)',
      difficulty: 'medium',
      points: 80,
      durationDays: 3,
      icon: '🎒',
    ),
    Challenge(
      id: 'ch8',
      title: 'Composting Hero',
      description: 'Mulai kompos organik dari sampah dapur',
      difficulty: 'medium',
      points: 90,
      durationDays: 5,
      icon: '🌾',
    ),
    Challenge(
      id: 'ch9',
      title: 'Digital Minimalist',
      description: 'Kurangi screen time 50% untuk hemat energi',
      difficulty: 'hard',
      points: 150,
      durationDays: 7,
      icon: '📱',
    ),
  ];
}
