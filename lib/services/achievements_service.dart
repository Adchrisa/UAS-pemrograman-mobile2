import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement_model.dart';

class AchievementsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static String _getUserId() {
    final user = _supabase.auth.currentUser;
    return user?.id ?? 'guest';
  }

  // Local cache keys (per user) for offline/guest
  static String get _keyUserStats => 'eco_user_stats_${_getUserId()}';
  static String get _keyUnlockedBadges => 'eco_unlocked_badges_${_getUserId()}';

  static final ValueNotifier<UserStats> statsNotifier = ValueNotifier(
    UserStats(lastCheckIn: DateTime.now()),
  );
  static final ValueNotifier<Set<String>> unlockedBadgesNotifier = ValueNotifier(<String>{});

  // Initialize service
  static Future<void> init() async {
    await _loadUserStats();
    await _loadUnlockedBadges();
  }

  // Load user stats
  static Future<void> _loadUserStats() async {
    // If logged in, prefer Supabase, fallback local cache
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final remote = await _fetchRemoteStats(user.id);
        if (remote != null) {
          statsNotifier.value = remote.stats;
          unlockedBadgesNotifier.value = remote.badges;
          await _cacheStats(remote.stats);
          await _cacheBadges(remote.badges);
          await _updateStreak();
          return;
        }
      } catch (_) {
        // fall through to local
      }
    }

    // Local cache
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUserStats);
    if (jsonStr != null) {
      final stats = UserStats.fromJson(jsonDecode(jsonStr));
      statsNotifier.value = stats;
      await _updateStreak();
      return;
    }

    // First time init
    final initStats = UserStats(lastCheckIn: DateTime.now());
    statsNotifier.value = initStats;
    await _saveUserStats(initStats);
  }

  // Save user stats
  static Future<void> _saveUserStats(UserStats stats) async {
    // Always cache locally
    await _cacheStats(stats);
    statsNotifier.value = stats;

    // If logged in, push to Supabase
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _upsertRemoteStats(user.id, stats, unlockedBadgesNotifier.value);
      } catch (_) {
        // ignore offline errors; cache already updated
      }
    }
  }

  // Update streak
  static Future<void> _updateStreak() async {
    final stats = statsNotifier.value;
    final now = DateTime.now();
    final lastCheckIn = stats.lastCheckIn;
    
    final daysDiff = now.difference(lastCheckIn).inDays;
    
    if (daysDiff == 0) {
      // Same day, no change
      return;
    } else if (daysDiff == 1) {
      // Consecutive day, increment streak
      final newStreak = stats.currentStreak + 1;
      final newStats = stats.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
        lastCheckIn: now,
      );
      await _saveUserStats(newStats);
    } else {
      // Streak broken
      final newStats = stats.copyWith(
        currentStreak: 1,
        lastCheckIn: now,
      );
      await _saveUserStats(newStats);
    }
  }

  // Daily check-in
  static Future<void> dailyCheckIn() async {
    await _updateStreak();
  }

  // Add points
  static Future<void> addPoints(int points) async {
    final stats = statsNotifier.value;
    final newStats = stats.copyWith(
      totalPoints: stats.totalPoints + points,
    );
    await _saveUserStats(newStats);
    await _checkBadgeUnlocks();
  }

  // Complete challenge
  static Future<void> completeChallenge(int points) async {
    final stats = statsNotifier.value;
    final newStats = stats.copyWith(
      completedChallenges: stats.completedChallenges + 1,
      totalPoints: stats.totalPoints + points,
    );
    await _saveUserStats(newStats);
    await _checkBadgeUnlocks();
  }

  // Complete tip
  static Future<void> completeTip(int points) async {
    final stats = statsNotifier.value;
    final newStats = stats.copyWith(
      completedTips: stats.completedTips + 1,
      totalPoints: stats.totalPoints + points,
    );
    await _saveUserStats(newStats);
    await _checkBadgeUnlocks();
  }

  // Add tree planted
  static Future<void> addTreePlanted(double co2) async {
    final stats = statsNotifier.value;
    final newStats = stats.copyWith(
      treesPlanted: stats.treesPlanted + 1,
      co2Saved: stats.co2Saved + co2,
    );
    await _saveUserStats(newStats);
    await _checkBadgeUnlocks();
  }

  // Load unlocked badges
  static Future<void> _loadUnlockedBadges() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final remote = await _fetchRemoteStats(user.id);
        final badges = remote?.badges ?? <String>{};
        unlockedBadgesNotifier.value = badges;
        await _cacheBadges(badges);
        return;
      } catch (_) {
        // fallback
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUnlockedBadges) ?? [];
    unlockedBadgesNotifier.value = list.toSet();
  }

  // Unlock badge
  static Future<void> _unlockBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUnlockedBadges) ?? [];
    if (!list.contains(badgeId)) {
      list.add(badgeId);
      await prefs.setStringList(_keyUnlockedBadges, list);
      unlockedBadgesNotifier.value = list.toSet();
      debugPrint('🏆 Badge Unlocked: $badgeId');
      await _cacheBadges(unlockedBadgesNotifier.value);
      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          await _upsertRemoteStats(user.id, statsNotifier.value, unlockedBadgesNotifier.value);
        } catch (_) {
          // ignore
        }
      }
    }
  }

  // Check and unlock badges based on stats
  static Future<void> _checkBadgeUnlocks() async {
    final stats = statsNotifier.value;
    final unlocked = unlockedBadgesNotifier.value;

    for (final badge in _allBadges) {
      if (unlocked.contains(badge.id)) continue; // Already unlocked

      bool shouldUnlock = false;

      switch (badge.id) {
        case 'first_steps':
          shouldUnlock = stats.totalPoints >= 10;
          break;
        case 'eco_starter':
          shouldUnlock = stats.totalPoints >= 50;
          break;
        case 'eco_warrior':
          shouldUnlock = stats.totalPoints >= 200;
          break;
        case 'eco_legend':
          shouldUnlock = stats.totalPoints >= 500;
          break;
        case 'streak_3':
          shouldUnlock = stats.currentStreak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = stats.currentStreak >= 7;
          break;
        case 'streak_30':
          shouldUnlock = stats.currentStreak >= 30;
          break;
        case 'tree_lover':
          shouldUnlock = stats.treesPlanted >= 1;
          break;
        case 'forest_keeper':
          shouldUnlock = stats.treesPlanted >= 5;
          break;
        case 'challenge_master':
          shouldUnlock = stats.completedChallenges >= 10;
          break;
        case 'tip_expert':
          shouldUnlock = stats.completedTips >= 20;
          break;
      }

      if (shouldUnlock) {
        await _unlockBadge(badge.id);
      }
    }
  }

  // Get all badges with unlock status
  static List<Badge> getAllBadges() {
    final unlocked = unlockedBadgesNotifier.value;
    return _allBadges.map((badge) {
      return Badge(
        id: badge.id,
        name: badge.name,
        description: badge.description,
        icon: badge.icon,
        requiredPoints: badge.requiredPoints,
        category: badge.category,
        unlockedDate: unlocked.contains(badge.id) ? DateTime.now() : null,
      );
    }).toList();
  }

  // Mock leaderboard (in production, fetch from backend)
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create list with mock users + current user
    final leaderboard = [
      {'name': 'EcoMaster', 'points': 1250, 'avatar': '🌟'},
      {'name': 'GreenGuru', 'points': 980, 'avatar': '🌱'},
      {'name': 'TreeHugger', 'points': 875, 'avatar': '🌳'},
      {'name': 'EarthSaver', 'points': 650, 'avatar': '🌍'},
      {'name': 'OceanGuard', 'points': 540, 'avatar': '🌊'},
      {'name': 'ClimateHero', 'points': 420, 'avatar': '⚡'},
      {'name': 'WasteWarrior', 'points': 380, 'avatar': '♻️'},
      {'name': 'SolarSoul', 'points': 310, 'avatar': '☀️'},
      {'name': 'BikeRider', 'points': 275, 'avatar': '🚴'},
      {'name': 'You', 'points': statsNotifier.value.totalPoints, 'avatar': '👤', 'isCurrentUser': true},
    ];
    
    // Sort by points descending
    leaderboard.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    
    // Assign ranks
    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i]['rank'] = i + 1;
    }
    
    return leaderboard;
  }

  // All badges database
  static final List<Badge> _allBadges = [
    const Badge(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Earn your first 10 points',
      icon: '👣',
      requiredPoints: 10,
      category: 'beginner',
    ),
    const Badge(
      id: 'eco_starter',
      name: 'Eco Starter',
      description: 'Reach 50 points',
      icon: '🌱',
      requiredPoints: 50,
      category: 'beginner',
    ),
    const Badge(
      id: 'eco_warrior',
      name: 'Eco Warrior',
      description: 'Reach 200 points',
      icon: '⚔️',
      requiredPoints: 200,
      category: 'intermediate',
    ),
    const Badge(
      id: 'eco_legend',
      name: 'Eco Legend',
      description: 'Reach 500 points',
      icon: '👑',
      requiredPoints: 500,
      category: 'expert',
    ),
    const Badge(
      id: 'streak_3',
      name: '3-Day Streak',
      description: 'Check in for 3 consecutive days',
      icon: '🔥',
      category: 'special',
    ),
    const Badge(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Check in for 7 consecutive days',
      icon: '📅',
      category: 'special',
    ),
    const Badge(
      id: 'streak_30',
      name: 'Month Master',
      description: 'Check in for 30 consecutive days',
      icon: '📆',
      category: 'expert',
    ),
    const Badge(
      id: 'tree_lover',
      name: 'Tree Lover',
      description: 'Plant your first tree',
      icon: '🌳',
      category: 'beginner',
    ),
    const Badge(
      id: 'forest_keeper',
      name: 'Forest Keeper',
      description: 'Plant 5 trees',
      icon: '🌲',
      category: 'intermediate',
    ),
    const Badge(
      id: 'challenge_master',
      name: 'Challenge Master',
      description: 'Complete 10 challenges',
      icon: '🏆',
      category: 'intermediate',
    ),
    const Badge(
      id: 'tip_expert',
      name: 'Tip Expert',
      description: 'Complete 20 daily tips',
      icon: '💡',
      category: 'intermediate',
    ),
  ];

  static Future<_RemoteStats?> _fetchRemoteStats(String userId) async {
    final data = await _supabase
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    final stats = _mapFromSupabase(data);
    final badges = (data['unlocked_badges'] as List?)
            ?.whereType<String>()
            .toSet() ??
        <String>{};
    return _RemoteStats(stats: stats, badges: badges);
  }

  static Future<void> _upsertRemoteStats(
    String userId,
    UserStats stats,
    Set<String> badges,
  ) async {
    final row = _rowFromStats(userId, stats, badges);
    await _supabase.from('user_stats').upsert(row);
  }

  static UserStats _mapFromSupabase(Map<String, dynamic> row) {
    return UserStats(
      totalPoints: row['total_points'] ?? 0,
      currentStreak: row['current_streak'] ?? 0,
      longestStreak: row['longest_streak'] ?? 0,
      completedChallenges: row['completed_challenges'] ?? 0,
      completedTips: row['completed_tips'] ?? 0,
      treesPlanted: row['trees_planted'] ?? 0,
      co2Saved: (row['co2_saved'] ?? 0).toDouble(),
      lastCheckIn: row['last_check_in'] != null
          ? DateTime.parse(row['last_check_in'].toString())
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> _rowFromStats(
    String userId,
    UserStats stats,
    Set<String> badges,
  ) {
    return {
      'user_id': userId,
      'total_points': stats.totalPoints,
      'current_streak': stats.currentStreak,
      'longest_streak': stats.longestStreak,
      'completed_challenges': stats.completedChallenges,
      'completed_tips': stats.completedTips,
      'trees_planted': stats.treesPlanted,
      'co2_saved': stats.co2Saved,
      'last_check_in': stats.lastCheckIn.toIso8601String(),
      'unlocked_badges': badges.toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> _cacheStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserStats, jsonEncode(stats.toJson()));
  }

  static Future<void> _cacheBadges(Set<String> badges) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyUnlockedBadges, badges.toList());
  }
}

class _RemoteStats {
  final UserStats stats;
  final Set<String> badges;

  const _RemoteStats({required this.stats, required this.badges});
}
