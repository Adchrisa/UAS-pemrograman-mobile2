class Article {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime date;

  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.date,
  });

  /// Factory constructor untuk parse data dari Supabase
  factory Article.fromSupabase(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      date: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON (untuk keperluan lain jika diperlukan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'created_at': date.toIso8601String(),
    };
  }
}
