import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticlesEvent extends ArticleEvent {
  const LoadArticlesEvent();
}

class LoadArticlesByCategoryEvent extends ArticleEvent {
  final String category;

  const LoadArticlesByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchArticlesEvent extends ArticleEvent {
  final String query;

  const SearchArticlesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshArticlesEvent extends ArticleEvent {
  const RefreshArticlesEvent();
}
