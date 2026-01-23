class Badge {
  final String id;
  final String name;
  final String description;
  final String icon; // Icon/emoji
  final int requiredPoints;
  final String category; // 'beginner', 'intermediate', 'expert', 'special'
  final DateTime? unlockedDate;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.requiredPoints = 0,
    this.category = 'beginner',
    this.unlockedDate,
  });

  bool get isUnlocked => unlockedDate != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'requiredPoints': requiredPoints,
    'category': category,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: json['icon'],
    requiredPoints: json['requiredPoints'] ?? 0,
    category: json['category'] ?? 'beginner',
    unlockedDate: json['unlockedDate'] != null ? DateTime.parse(json['unlockedDate']) : null,
  );
}

class UserStats {
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;
  final int completedTips;
  final int treesPlanted;
  final double co2Saved;
  final DateTime lastCheckIn;

  const UserStats({
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedChallenges = 0,
    this.completedTips = 0,
    this.treesPlanted = 0,
    this.co2Saved = 0.0,
    required this.lastCheckIn,
  });

  Map<String, dynamic> toJson() => {
    'totalPoints': totalPoints,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'completedChallenges': completedChallenges,
    'completedTips': completedTips,
    'treesPlanted': treesPlanted,
    'co2Saved': co2Saved,
    'lastCheckIn': lastCheckIn.toIso8601String(),
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalPoints: json['totalPoints'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    completedChallenges: json['completedChallenges'] ?? 0,
    completedTips: json['completedTips'] ?? 0,
    treesPlanted: json['treesPlanted'] ?? 0,
    co2Saved: (json['co2Saved'] ?? 0).toDouble(),
    lastCheckIn: DateTime.parse(json['lastCheckIn']),
  );

  UserStats copyWith({
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? completedChallenges,
    int? completedTips,
    int? treesPlanted,
    double? co2Saved,
    DateTime? lastCheckIn,
  }) {
    return UserStats(
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      completedTips: completedTips ?? this.completedTips,
      treesPlanted: treesPlanted ?? this.treesPlanted,
      co2Saved: co2Saved ?? this.co2Saved,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    );
  }
}
