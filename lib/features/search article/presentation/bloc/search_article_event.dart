import 'package:equatable/equatable.dart';

abstract class SearchArticleEvent extends Equatable {
  const SearchArticleEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchArticleEvent {
  final String query;

  const SearchQueryChanged({required this.query});

  @override
  List<Object> get props => [query];
}
