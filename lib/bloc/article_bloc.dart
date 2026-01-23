import 'package:flutter_bloc/flutter_bloc.dart';
import 'article_event.dart';
import 'article_state.dart';
import '../services/api_service.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ApiService apiService;

  ArticleBloc({required this.apiService}) : super(const ArticleInitial()) {
    on<LoadArticlesEvent>(_onLoadArticles);
    on<LoadArticlesByCategoryEvent>(_onLoadArticlesByCategory);
    on<SearchArticlesEvent>(_onSearchArticles);
    on<RefreshArticlesEvent>(_onRefreshArticles);
  }

  Future<void> _onLoadArticles(
    LoadArticlesEvent event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleLoading());
    try {
      final articles = await apiService.fetchArticles();
      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      emit(ArticleError('Gagal memuat artikel: ${e.toString()}'));
    }
  }

  Future<void> _onLoadArticlesByCategory(
    LoadArticlesByCategoryEvent event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleLoading());
    try {
      final articles = await apiService.fetchArticlesByCategory(event.category);
      emit(ArticleLoaded(
        articles: articles,
        activeCategory: event.category,
      ));
    } catch (e) {
      emit(ArticleError('Gagal memuat artikel kategori ${event.category}: ${e.toString()}'));
    }
  }

  Future<void> _onSearchArticles(
    SearchArticlesEvent event,
    Emitter<ArticleState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadArticlesEvent());
      return;
    }

    emit(const ArticleLoading());
    try {
      final articles = await apiService.searchArticles(event.query);
      emit(ArticleLoaded(
        articles: articles,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ArticleError('Gagal mencari artikel: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshArticles(
    RefreshArticlesEvent event,
    Emitter<ArticleState> emit,
  ) async {
    try {
      final articles = await apiService.fetchArticles();
      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      emit(ArticleError('Gagal refresh artikel: ${e.toString()}'));
    }
  }
}
