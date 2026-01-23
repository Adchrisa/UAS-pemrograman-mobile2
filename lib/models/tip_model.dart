class DailyTip {
  final String id;
  final String title;
  final String description;
  final String category; // 'energy', 'waste', 'water', 'transport'
  final int points; // Points earned when completed
  final DateTime date;

  const DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.points = 10,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'points': points,
    'date': date.toIso8601String(),
  };

  factory DailyTip.fromJson(Map<String, dynamic> json) => DailyTip(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    points: json['points'] ?? 10,
    date: DateTime.parse(json['date']),
  );
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String difficulty; // 'easy', 'medium', 'hard'
  final int points;
  final int durationDays; // Challenge duration
  final String icon; // Icon name

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.difficulty = 'medium',
    this.points = 50,
    this.durationDays = 1,
    this.icon = 'star',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'points': points,
    'durationDays': durationDays,
    'icon': icon,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    difficulty: json['difficulty'] ?? 'medium',
    points: json['points'] ?? 50,
    durationDays: json['durationDays'] ?? 1,
    icon: json['icon'] ?? 'star',
  );
}

class ChallengeProgress {
  final String challengeId;
  final DateTime startDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final int progress; // 0-100

  const ChallengeProgress({
    required this.challengeId,
    required this.startDate,
    this.completedDate,
    this.isCompleted = false,
    this.progress = 0,
  });

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'startDate': startDate.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'progress': progress,
  };

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) => ChallengeProgress(
    challengeId: json['challengeId'],
    startDate: DateTime.parse(json['startDate']),
    completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    isCompleted: json['isCompleted'] ?? false,
    progress: json['progress'] ?? 0,
  );
}
