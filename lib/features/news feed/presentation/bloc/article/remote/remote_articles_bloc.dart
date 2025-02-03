import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_clustered_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_similar_articles.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticlesUseCase getArticlesUseCase;
  final GetSimilarArticlesUseCase getSimilarArticlesUseCase;
  final GetClusteredArticlesUseCase  getClusteredArticlesUseCase;

  RemoteArticlesBloc(this.getArticlesUseCase, this.getClusteredArticlesUseCase, this.getSimilarArticlesUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<GetArticlesFromDifferentCategory>(onGetArticlesFromDifferentCategory);
    on<GetSimilarArticles>(onGetSimilarArticles);
    on<GetClusteredArticles>(onGetClusteredArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    emit(RemoteArticlesLoadingMoreArticles());
    final dataState = await getArticlesUseCase(params: event.getArticlesParams);

    if (dataState is DataSuccess) {
      if(dataState.data?.articleList !=null) {
        emit(RemoteArticlesFetched(dataState.data??ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onGetArticlesFromDifferentCategory(
      GetArticlesFromDifferentCategory event, Emitter<RemoteArticlesState> emit) async {
    emit(RemoteArticlesLoading());
    final dataState = await getArticlesUseCase(params: event.getArticlesParams);

    if (dataState is DataSuccess) {
      if(dataState.data?.articleList !=null) {
        emit(RemoteArticlesFetchedFromDifferentCategory(dataState.data??ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onGetSimilarArticles(GetSimilarArticles event, Emitter<RemoteArticlesState> emit) async{
    emit(RemoteSimilarArticlesLoading());

    final dataState = await getSimilarArticlesUseCase(params: event.params);

    if (dataState is DataSuccess) {
      if(dataState.data?.articleList !=null) {
        emit(RemoteSimilarArticlesFetched(dataState.data??ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onGetClusteredArticles(GetClusteredArticles event, Emitter<RemoteArticlesState> emit) async{
    emit(RemoteClusteredArticlesLoading());

    final dataState = await getClusteredArticlesUseCase(params: event.article);

    if (dataState is DataSuccess) {
      if(dataState.data?.articleList !=null) {
        emit(RemoteClusteredArticlesFetched(dataState.data??ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }
}
