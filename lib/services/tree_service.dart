import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tree_model.dart';
import 'achievements_service.dart';

class TreeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID untuk per-user storage
  static String _getUserId() {
    final user = _supabase.auth.currentUser;
    return user?.id ?? 'guest'; // fallback ke 'guest' jika tidak login
  }

  // Dynamic keys berdasarkan user ID (local cache)
  static String get _keyCurrentTree => 'eco_current_tree_${_getUserId()}';
  static String get _keyEcoPoints => 'eco_points_${_getUserId()}';
  static String get _keyUnlockedSpecies => 'eco_unlocked_species_${_getUserId()}';
  static String get _keyFertilizerCount => 'eco_fertilizer_count_${_getUserId()}';

  static final ValueNotifier<TreeModel?> currentTreeNotifier =
      ValueNotifier<TreeModel?>(null);
  static final ValueNotifier<int> ecoPointsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> fertilizerCountNotifier = ValueNotifier<int>(0);

  // Initialize service
  static Future<void> init() async {
    await _loadTree();
    await _loadEcoPoints();
    await _loadFertilizerCount();
    await _loadUnlockedSpecies();
  }

  // Load current tree from Supabase (if logged in) or local cache
  static Future<void> _loadTree() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('user_garden')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (data != null && data['current_tree'] != null) {
          final tree = TreeModel.fromJson(data['current_tree']);
          _updateTreeHealth(tree);
          currentTreeNotifier.value = tree;
          await _cacheTree(tree);
          return;
        } else if (data != null && data['current_tree'] == null) {
          // Remote is empty; clear local cache too
          await _clearCachedTree();
          currentTreeNotifier.value = null;
          return;
        }
      } catch (_) {
        // fallback to local
      }
    }

    // Local cache
    final prefs = await SharedPreferences.getInstance();
    final treeJson = prefs.getString(_keyCurrentTree);
    
    if (treeJson != null) {
      final tree = TreeModel.fromJson(jsonDecode(treeJson));
      _updateTreeHealth(tree);
      currentTreeNotifier.value = tree;
    }
  }

  // Save tree to Supabase (if logged in) and local cache
  static Future<void> _saveTree(TreeModel tree) async {
    // Always cache locally
    await _cacheTree(tree);
    currentTreeNotifier.value = tree;

    // If logged in, push to Supabase
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_garden').upsert({
          'user_id': user.id,
          'current_tree': tree.toJson(),
          'days_active': tree.ageInDays,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore offline errors
      }
    }
  }

  static Future<void> _cacheTree(TreeModel tree) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentTree, jsonEncode(tree.toJson()));
  }

  static Future<void> _clearCachedTree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentTree);
  }

  // Load eco points from Supabase (if logged in) or local cache
  static Future<void> _loadEcoPoints() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('user_garden')
            .select('eco_points')
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (data != null && data['eco_points'] != null) {
          final points = data['eco_points'] as int;
          ecoPointsNotifier.value = points;
          await _cacheEcoPoints(points);
          return;
        }
      } catch (_) {
        // fallback
      }
    }

    final prefs = await SharedPreferences.getInstance();
    ecoPointsNotifier.value = prefs.getInt(_keyEcoPoints) ?? 50;
  }

  // Save eco points to Supabase and local cache
  static Future<void> _saveEcoPoints(int points) async {
    await _cacheEcoPoints(points);
    ecoPointsNotifier.value = points;

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_garden').upsert({
          'user_id': user.id,
          'eco_points': points,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore
      }
    }
  }

  static Future<void> _cacheEcoPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEcoPoints, points);
  }

  // Load fertilizer count from Supabase (if logged in) or local cache
  static Future<void> _loadFertilizerCount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('user_garden')
            .select('fertilizer_count')
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (data != null && data['fertilizer_count'] != null) {
          final count = data['fertilizer_count'] as int;
          fertilizerCountNotifier.value = count;
          await _cacheFertilizerCount(count);
          return;
        }
      } catch (_) {
        // fallback
      }
    }

    final prefs = await SharedPreferences.getInstance();
    fertilizerCountNotifier.value = prefs.getInt(_keyFertilizerCount) ?? 0;
  }

  // Save fertilizer count to Supabase and local cache
  static Future<void> _saveFertilizerCount(int count) async {
    await _cacheFertilizerCount(count);
    fertilizerCountNotifier.value = count;

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_garden').upsert({
          'user_id': user.id,
          'fertilizer_count': count,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore
      }
    }
  }

  static Future<void> _cacheFertilizerCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFertilizerCount, count);
  }

  // Load unlocked species from Supabase (if logged in) or local cache
  static Future<void> _loadUnlockedSpecies() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('user_garden')
            .select('unlocked_species')
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (data != null && data['unlocked_species'] != null) {
          final species = List<String>.from(data['unlocked_species'] as List);
          await _cacheUnlockedSpecies(species);
          return;
        }
      } catch (_) {
        // fallback
      }
    }

    // Local cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.getStringList(_keyUnlockedSpecies) ?? ['oak'];
  }

  static Future<void> _cacheUnlockedSpecies(List<String> species) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyUnlockedSpecies, species);
  }

  static Future<void> _syncUnlockedSpeciesToSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final species = prefs.getStringList(_keyUnlockedSpecies) ?? ['oak'];
        
        await _supabase.from('user_garden').upsert({
          'user_id': user.id,
          'unlocked_species': species,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore
      }
    }
  }

  // Plant a new tree
  static Future<bool> plantTree(String name, TreeSpecies species) async {
    if (currentTreeNotifier.value != null && currentTreeNotifier.value!.isAlive) {
      return false; // Already have an active tree
    }

    final tree = TreeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      species: species,
      lastWatered: DateTime.now(),
      plantedDate: DateTime.now(),
    );

    await _saveTree(tree);
    
    // Add to achievements stats: 1 tree planted, estimate ~20kg CO2 per tree
    await AchievementsService.addTreePlanted(20.0);
    
    return true;
  }

  // Water the tree
  static Future<String> waterTree() async {
    final tree = currentTreeNotifier.value;
    if (tree == null || !tree.isAlive) {
      return 'Tidak ada pohon aktif';
    }

    final hoursSinceWatered = DateTime.now().difference(tree.lastWatered).inHours;
    
    if (hoursSinceWatered < 5) {
      return 'Pohon sudah disiram hari ini! 💧';
    }

    // Water the tree - increase health
    double newHealth = (tree.healthPoints + 20).clamp(0, 100);
    
    final updatedTree = tree.copyWith(
      lastWatered: DateTime.now(),
      healthPoints: newHealth,
    );

    await _saveTree(updatedTree);
    
    // Give eco points for daily care
    await addEcoPoints(5);
    
    return 'Pohon berhasil disiram! +5 poin 🌱';
  }

  // Fertilize the tree
  static Future<String> fertilizeTree() async {
    final tree = currentTreeNotifier.value;
    if (tree == null || !tree.isAlive) {
      return 'Tidak ada pohon aktif';
    }

    if (fertilizerCountNotifier.value <= 0) {
      return 'Pupuk habis! Beli di shop 🛒';
    }

    // Apply fertilizer - boost growth and health
    double newHealth = (tree.healthPoints + 30).clamp(0, 100);
    
    final updatedTree = tree.copyWith(
      lastFertilized: DateTime.now(),
      healthPoints: newHealth,
    );

    await _saveTree(updatedTree);
    await _saveFertilizerCount(fertilizerCountNotifier.value - 1);
    
    // Check if tree can grow to next stage
    await _checkGrowthStage();
    
    return 'Pupuk berhasil diberikan! Pertumbuhan meningkat 🌿';
  }

  // Update tree health based on time passed
  static void _updateTreeHealth(TreeModel tree) {
    final hoursSinceWatered = DateTime.now().difference(tree.lastWatered).inHours;
    
    // Decrease health if not watered
    if (hoursSinceWatered >= 24) {
      final daysWithoutWater = hoursSinceWatered ~/ 24;
      double healthDecrease = daysWithoutWater * 10.0;
      tree.healthPoints = (tree.healthPoints - healthDecrease).clamp(0, 100);
      
      // Tree dies if health reaches 0
      if (tree.healthPoints <= 0) {
        tree.isAlive = false;
      }
    }
  }

  // Check and update growth stage
  static Future<void> _checkGrowthStage() async {
    final tree = currentTreeNotifier.value;
    if (tree == null || !tree.isAlive || tree.growthStage >= 5) return;

    final daysOld = tree.ageInDays;
    final species = tree.species;
    
    // Calculate expected stage based on age and species
    // Each stage takes different days based on species growth speed
    final daysPerStage = (7 / species.growthSpeed).round();
    final expectedStage = (daysOld / daysPerStage).floor().clamp(0, 5);
    
    // Bonus from fertilizer
    final hoursSinceFertilized = tree.lastFertilized != null
        ? DateTime.now().difference(tree.lastFertilized!).inHours
        : 999;
    
    int bonusStage = 0;
    if (hoursSinceFertilized < 48) {
      bonusStage = 1; // Fertilizer gives 1 stage boost
    }
    
    final newStage = (expectedStage + bonusStage).clamp(0, 5);
    
    if (newStage > tree.growthStage) {
      final updatedTree = tree.copyWith(growthStage: newStage);
      await _saveTree(updatedTree);
      
      // Reward for reaching new stage
      await addEcoPoints(20);
    }
  }

  // Add eco points
  static Future<void> addEcoPoints(int points) async {
    final currentPoints = ecoPointsNotifier.value;
    await _saveEcoPoints(currentPoints + points);
  }

  // Spend eco points
  static Future<bool> spendEcoPoints(int points) async {
    final currentPoints = ecoPointsNotifier.value;
    if (currentPoints < points) return false;
    
    await _saveEcoPoints(currentPoints - points);
    return true;
  }

  // Buy fertilizer
  static Future<String> buyFertilizer(int quantity) async {
    final cost = quantity * 10; // 10 points per fertilizer
    
    if (await spendEcoPoints(cost)) {
      final newCount = fertilizerCountNotifier.value + quantity;
      await _saveFertilizerCount(newCount);
      return 'Berhasil membeli $quantity pupuk! 🎉';
    }
    
    return 'Poin tidak cukup! Butuh $cost poin';
  }

  // Check if species is unlocked
  static Future<bool> isSpeciesUnlocked(TreeSpecies species) async {
    if (species == TreeSpecies.oak) return true; // Oak is always unlocked
    
    final prefs = await SharedPreferences.getInstance();
    final unlockedList = prefs.getStringList(_keyUnlockedSpecies) ?? [];
    return unlockedList.contains(species.name);
  }

  // Unlock new species
  static Future<String> unlockSpecies(TreeSpecies species) async {
    if (await isSpeciesUnlocked(species)) {
      return 'Spesies sudah terbuka';
    }
    
    final cost = species.unlockCost;
    if (await spendEcoPoints(cost)) {
      final prefs = await SharedPreferences.getInstance();
      final unlockedList = prefs.getStringList(_keyUnlockedSpecies) ?? [];
      unlockedList.add(species.name);
      await _cacheUnlockedSpecies(unlockedList);
      
      // Sync to Supabase
      await _syncUnlockedSpeciesToSupabase();
      
      return 'Berhasil unlock ${species.displayName}! 🎊';
    }
    
    return 'Poin tidak cukup! Butuh $cost poin';
  }

  // Get growth progress percentage (0-100)
  static double getGrowthProgress() {
    final tree = currentTreeNotifier.value;
    if (tree == null || !tree.isAlive) return 0;
    
    if (tree.growthStage >= 5) return 100; // Max stage
    
    // Use fractional days for smoother progress (updates within the same day)
    final hoursOld = DateTime.now().difference(tree.plantedDate).inHours;
    final daysOld = hoursOld / 24.0;
    final species = tree.species;
    final double daysPerStage = 7 / species.growthSpeed;
    
    final stageStartDay = tree.growthStage * daysPerStage;
    final stageEndDay = (tree.growthStage + 1) * daysPerStage;
    
    final progressInStage = ((daysOld - stageStartDay) / (stageEndDay - stageStartDay) * 100)
        .clamp(0, 100);
    
    return progressInStage.toDouble();
  }

  // Harvest mature tree (complete lifecycle)
  static Future<String> harvestTree() async {
    final tree = currentTreeNotifier.value;
    if (tree == null || !tree.isAlive) {
      return 'Tidak ada pohon untuk dipanen';
    }
    
    if (tree.growthStage < 5) {
      return 'Pohon belum cukup dewasa untuk dipanen';
    }
    
    // Reward based on tree age and health
    final reward = (tree.healthPoints * 5).round() + (tree.ageInDays * 2);
    await addEcoPoints(reward);
    
    // Calculate CO2 saved: mature tree = ~50kg CO2 per year, average lifespan
    final co2Contribution = 50.0 + (tree.ageInDays * 0.5);
    await AchievementsService.addTreePlanted(co2Contribution);
    
    // Remove current tree
    await deleteCurrentTree();
    
    return 'Pohon berhasil dipanen! +$reward poin 🎉\nSekarang kamu bisa menanam pohon baru!';
  }

  // Delete current tree manually (clear local + Supabase)
  static Future<void> deleteCurrentTree() async {
    await _clearCachedTree();
    currentTreeNotifier.value = null;

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_garden').upsert({
          'user_id': user.id,
          'current_tree': null,
          'days_active': 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore offline errors
      }
    }
  }

  // Daily check-in (auto-run when app opens)
  static Future<void> dailyCheckIn() async {
    final tree = currentTreeNotifier.value;
    if (tree == null) return;
    
    _updateTreeHealth(tree);
    await _checkGrowthStage();
    
    if (tree.isAlive) {
      await _saveTree(tree);
    }
  }
}
