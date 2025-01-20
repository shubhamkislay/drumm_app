import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_articles.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticlesUseCase getArticlesUseCase;

  RemoteArticlesBloc(this.getArticlesUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await getArticlesUseCase(params: event.category);

    if (dataState is DataSuccess) {
      emit(RemoteArticlesFetched(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }
}
