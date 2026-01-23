class TreeModel {
  final String id;
  final String name;
  final TreeSpecies species;
  int growthStage; // 0-5: seed, sprout, sapling, young, mature, fruiting
  double healthPoints; // 0-100
  DateTime lastWatered;
  DateTime? lastFertilized;
  final DateTime plantedDate;
  bool isAlive;

  TreeModel({
    required this.id,
    required this.name,
    required this.species,
    this.growthStage = 0,
    this.healthPoints = 100.0,
    required this.lastWatered,
    this.lastFertilized,
    required this.plantedDate,
    this.isAlive = true,
  });

  // Calculate growth progress percentage within current stage
  double get growthProgress {
    // This will be calculated based on time since last stage change
    return 0.0; // Placeholder, will be calculated in service
  }

  // Check if tree needs water
  bool get needsWater {
    final hoursSinceWatered = DateTime.now().difference(lastWatered).inHours;
    return hoursSinceWatered >= 24;
  }

  // Check if tree is thirsty (warning state)
  bool get isThirsty {
    final hoursSinceWatered = DateTime.now().difference(lastWatered).inHours;
    return hoursSinceWatered >= 48;
  }

  // Get health status
  String get healthStatus {
    if (healthPoints >= 80) return 'Sehat';
    if (healthPoints >= 60) return 'Baik';
    if (healthPoints >= 40) return 'Perlu Perhatian';
    if (healthPoints >= 20) return 'Lemah';
    return 'Sekarat';
  }

  // Get stage name
  String get stageName {
    switch (growthStage) {
      case 0:
        return 'Benih';
      case 1:
        return 'Kecambah';
      case 2:
        return 'Bibit';
      case 3:
        return 'Pohon Muda';
      case 4:
        return 'Pohon Dewasa';
      case 5:
        return 'Berbuah';
      default:
        return 'Unknown';
    }
  }

  // Get age in days
  int get ageInDays {
    return DateTime.now().difference(plantedDate).inDays;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species.name,
      'growthStage': growthStage,
      'healthPoints': healthPoints,
      'lastWatered': lastWatered.toIso8601String(),
      'lastFertilized': lastFertilized?.toIso8601String(),
      'plantedDate': plantedDate.toIso8601String(),
      'isAlive': isAlive,
    };
  }

  // Create from JSON
  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
      id: json['id'],
      name: json['name'],
      species: TreeSpecies.values.firstWhere(
        (e) => e.name == json['species'],
        orElse: () => TreeSpecies.oak,
      ),
      growthStage: json['growthStage'],
      healthPoints: json['healthPoints'].toDouble(),
      lastWatered: DateTime.parse(json['lastWatered']),
      lastFertilized: json['lastFertilized'] != null
          ? DateTime.parse(json['lastFertilized'])
          : null,
      plantedDate: DateTime.parse(json['plantedDate']),
      isAlive: json['isAlive'],
    );
  }

  // Copy with
  TreeModel copyWith({
    String? id,
    String? name,
    TreeSpecies? species,
    int? growthStage,
    double? healthPoints,
    DateTime? lastWatered,
    DateTime? lastFertilized,
    DateTime? plantedDate,
    bool? isAlive,
  }) {
    return TreeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      growthStage: growthStage ?? this.growthStage,
      healthPoints: healthPoints ?? this.healthPoints,
      lastWatered: lastWatered ?? this.lastWatered,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      plantedDate: plantedDate ?? this.plantedDate,
      isAlive: isAlive ?? this.isAlive,
    );
  }
}

// Tree species with different characteristics
enum TreeSpecies {
  oak,
  pine,
  bamboo,
  mangrove,
  cherry,
  maple;

  String get displayName {
    switch (this) {
      case TreeSpecies.oak:
        return 'Pohon Oak';
      case TreeSpecies.pine:
        return 'Pohon Pinus';
      case TreeSpecies.bamboo:
        return 'Bambu';
      case TreeSpecies.mangrove:
        return 'Mangrove';
      case TreeSpecies.cherry:
        return 'Pohon Sakura';
      case TreeSpecies.maple:
        return 'Pohon Maple';
    }
  }

  String get description {
    switch (this) {
      case TreeSpecies.oak:
        return 'Pohon kuat yang tumbuh lambat tapi kokoh';
      case TreeSpecies.pine:
        return 'Pohon evergreen yang tahan cuaca ekstrem';
      case TreeSpecies.bamboo:
        return 'Tumbuh super cepat, cocok untuk pemula';
      case TreeSpecies.mangrove:
        return 'Pelindung pesisir, menyerap CO2 tinggi';
      case TreeSpecies.cherry:
        return 'Pohon cantik dengan bunga musim semi';
      case TreeSpecies.maple:
        return 'Pohon dengan daun merah yang indah';
    }
  }

  // Growth speed multiplier
  double get growthSpeed {
    switch (this) {
      case TreeSpecies.oak:
        return 0.8; // Slower
      case TreeSpecies.pine:
        return 1.0; // Normal
      case TreeSpecies.bamboo:
        return 1.5; // Faster
      case TreeSpecies.mangrove:
        return 1.1;
      case TreeSpecies.cherry:
        return 0.9;
      case TreeSpecies.maple:
        return 1.0;
    }
  }

  // Unlock cost in eco points
  int get unlockCost {
    switch (this) {
      case TreeSpecies.oak:
        return 0; // Free starter
      case TreeSpecies.pine:
        return 100;
      case TreeSpecies.bamboo:
        return 50;
      case TreeSpecies.mangrove:
        return 200;
      case TreeSpecies.cherry:
        return 300;
      case TreeSpecies.maple:
        return 250;
    }
  }
}
