import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:equatable/equatable.dart';

abstract class SearchArticleState extends Equatable {
  const SearchArticleState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchArticleState {}

class SearchLoading extends SearchArticleState {}

class SearchLoaded extends SearchArticleState {
  final List<ArticleEntity> articles;

  const SearchLoaded({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class SearchError extends SearchArticleState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
