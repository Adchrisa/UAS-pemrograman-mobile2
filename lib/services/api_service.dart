import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article_model.dart';

/// Service untuk mengambil data artikel dari Supabase
class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch semua artikel dari Supabase
  Future<List<Article>> fetchArticles() async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);

      final List<Article> articles = (response as List)
          .map((json) => Article.fromSupabase(json))
          .toList();

      return articles;
    } catch (e) {
      throw Exception('Gagal mengambil artikel: $e');
    }
  }

  /// Fetch artikel berdasarkan kategori
  Future<List<Article>> fetchArticlesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      final List<Article> articles = (response as List)
          .map((json) => Article.fromSupabase(json))
          .toList();

      return articles;
    } catch (e) {
      throw Exception('Gagal mengambil artikel kategori $category: $e');
    }
  }

  /// Search artikel berdasarkan query
  Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .or('title.ilike.%$query%,subtitle.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<Article> articles = (response as List)
          .map((json) => Article.fromSupabase(json))
          .toList();

      return articles;
    } catch (e) {
      throw Exception('Gagal mencari artikel: $e');
    }
  }

  /// Fetch artikel by ID
  Future<Article?> fetchArticleById(String id) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .eq('id', id)
          .single();

      return Article.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal mengambil artikel dengan id $id: $e');
    }
  }
}
