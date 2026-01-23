import 'package:equatable/equatable.dart';
import '../models/article_model.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInitial extends ArticleState {
  const ArticleInitial();
}

class ArticleLoading extends ArticleState {
  const ArticleLoading();
}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  final String? activeCategory;
  final String? searchQuery;

  const ArticleLoaded({
    required this.articles,
    this.activeCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [articles, activeCategory, searchQuery];

  ArticleLoaded copyWith({
    List<Article>? articles,
    String? activeCategory,
    String? searchQuery,
  }) {
    return ArticleLoaded(
      articles: articles ?? this.articles,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
