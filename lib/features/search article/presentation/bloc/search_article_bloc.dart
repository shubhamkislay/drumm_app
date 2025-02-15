import 'package:drumm_app/features/search%20article/domain/usecases/search_articles.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_event.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchArticleBloc extends Bloc<SearchArticleEvent, SearchArticleState> {
  final SearchArticlesUseCase searchArticlesUseCase;

  SearchArticleBloc({required this.searchArticlesUseCase})
      : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchArticleState> emit) async {
    final query = event.query;
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
      final articles = await searchArticlesUseCase(query);
      emit(SearchLoaded(articles: articles));
    } catch (error) {
      emit(SearchError(message: error.toString()));
    }
  }
}
