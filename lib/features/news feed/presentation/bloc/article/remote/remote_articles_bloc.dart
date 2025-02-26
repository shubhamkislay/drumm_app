import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/generate_and_load_recommended_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_clustered_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_interaction_counts.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_latest_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_similar_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/mark_articles_as_seen.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/perform_vector_search.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/vector_search_and_load_recommended_articles.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticlesUseCase getArticlesUseCase;
  final GetSimilarArticlesUseCase getSimilarArticlesUseCase;
  final GetClusteredArticlesUseCase getClusteredArticlesUseCase;
  final PerformVectorSearchUseCase performVectorSearchUseCase;
  final GetLatestArticlesUseCase getLatestArticlesUseCase;
  final GetInteractionCountsUseCase getInteractionCountsUseCase;
  final VectorSearchAndLoadRecommendedArticlesUseCase
      vectorSearchAndLoadRecommendedArticlesUseCase;
  final GenerateAndLoadRecommendedArticlesUseCase
      generateAndLoadRecommendedArticlesUseCase;
  final MarkArticlesAsSeenUseCase markArticlesAsSeenUseCase;

  RemoteArticlesBloc(
      this.getArticlesUseCase,
      this.getClusteredArticlesUseCase,
      this.getSimilarArticlesUseCase,
      this.performVectorSearchUseCase,
      this.getLatestArticlesUseCase,
      this.getInteractionCountsUseCase,
      this.vectorSearchAndLoadRecommendedArticlesUseCase,
      this.generateAndLoadRecommendedArticlesUseCase,
      this.markArticlesAsSeenUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<GetRecommendedArticles>(onGetRecommendedArticles);
    on<GetArticlesFromDifferentCategory>(onGetArticlesFromDifferentCategory);
    on<GetSimilarArticles>(onGetSimilarArticles);
    on<GetClusteredArticles>(onGetClusteredArticles);
    on<MarkArticleAsSeen>(onMarkArticleAsSeen);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    List<String>? category =
        List<String>.from(event.getArticlesParams.category ?? ["For You"]);
    emit(RemoteArticlesLoadingMoreArticles());
    final dataState = await getArticlesUseCase(params: event.getArticlesParams);

    if (dataState is DataSuccess) {
      if (dataState.data?.articleList != null) {
        emit(RemoteArticlesFetched(
            dataState.data ?? ArticleListEntity(), category));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onGetRecommendedArticles(
      GetRecommendedArticles event, Emitter<RemoteArticlesState> emit) async {
    final List<String> category =
        List<String>.from(event.getArticlesParams.category ?? ["For You"]);
    print("Emitting category ${category}");
    emit(RemoteArticlesLoadingMoreArticles());

    if (event.getArticlesParams.drummerEntity?.preference != null) {
      if (!CoreUtils.isTimestampWithinThreeHours(
          event.getArticlesParams.drummerEntity?.lastRecommendationTimestamp ??
              Timestamp.fromDate(DateTime(2000)))) {
        print("Before calling getArticlesUseCase category ${category}");
        final dataState =
            await getArticlesUseCase(params: event.getArticlesParams);
        if (dataState is DataSuccess && dataState.data?.articleList != null) {
          print("After calling getArticlesUseCase category ${category}");
          emit(GeneratingRecommendation(dataState.data ?? ArticleListEntity(),
              event.getArticlesParams.category ?? []));
          final vectorDataState =
              await vectorSearchAndLoadRecommendedArticlesUseCase(
                  params: event.getArticlesParams);

          if (vectorDataState is DataSuccess) {
            emit(GeneratedRecommendationArticle());
          }
          if (vectorDataState is DataFailed) {
            emit(NoNewRecommendations());
          }
        } else {
          final latestdataState =
              await getLatestArticlesUseCase(params: event.getArticlesParams);

          if (latestdataState is DataSuccess &&
              latestdataState.data?.articleList != null) {
            emit(GeneratingRecommendation(
                latestdataState.data ?? ArticleListEntity(),
                event.getArticlesParams.category ?? []));
            final vectorDataState =
                await vectorSearchAndLoadRecommendedArticlesUseCase(
                    params: event.getArticlesParams);

            if (vectorDataState is DataSuccess) {
              emit(GeneratedRecommendationArticle());
            }
            if (vectorDataState is DataFailed) {
              emit(NoNewRecommendations());
            }
          } else {
            emit(RemoteArticlesError(dataState.error!));
          }
        }
      } else {
        print("Before calling getArticlesUseCase 2 category ${category}");
        final dataState =
            await getArticlesUseCase(params: event.getArticlesParams);

        if (dataState is DataSuccess) {
          if (dataState.data?.articleList != null) {
            print("After calling getArticlesUseCase 2 category ${category}");
            emit(RemoteArticlesFetched(
                dataState.data ?? ArticleListEntity(), category));
            //print("Emitting category ${event.getArticlesParams.category}");
          }
        }
        if (dataState is DataFailed) {
          final dataState =
              await getLatestArticlesUseCase(params: event.getArticlesParams);

          if (dataState is DataSuccess) {
            if (dataState.data?.articleList != null) {
              emit(RemoteArticlesFetched(
                  dataState.data ?? ArticleListEntity(), category));
              // int interactions = await getInteractionCountsUseCase();
              // if (interactions < 10) {
              //   emit(InteractToGenerateRecommendation(10 - interactions, category));
              // } else {
              emit(GeneratingRecommendation(
                  dataState.data ?? ArticleListEntity(), category));
              final vectorDataState =
                  await generateAndLoadRecommendedArticlesUseCase(
                      params: event.getArticlesParams);

              if (vectorDataState is DataSuccess) {
                emit(GeneratedRecommendationArticle());
              }
              if (vectorDataState is DataFailed) {
                emit(NoNewRecommendations());
              }
              //}
            }
          }
          if (dataState is DataFailed) {
            emit(RemoteArticlesError(dataState.error!));
          }
        }
      }
    } else {
      final dataState =
          await getLatestArticlesUseCase(params: event.getArticlesParams);

      if (dataState is DataSuccess) {
        if (dataState.data?.articleList != null) {
          emit(RemoteArticlesFetched(
              dataState.data ?? ArticleListEntity(), category));
          // int interactions = await getInteractionCountsUseCase();
          // if (interactions < 10) {
          //   emit(InteractToGenerateRecommendation(10 - interactions, category));
          // } else {
          emit(GeneratingRecommendation(
              dataState.data ?? ArticleListEntity(), category));
          final vectorDataState =
              await generateAndLoadRecommendedArticlesUseCase(
                  params: event.getArticlesParams);

          if (vectorDataState is DataSuccess) {
            emit(GeneratedRecommendationArticle());
          }
          if (vectorDataState is DataFailed) {
            emit(NoNewRecommendations());
          }
          // }
        }
      }
      if (dataState is DataFailed) {
        emit(RemoteArticlesError(dataState.error!));
      }
    }
  }

  void onGetArticlesFromDifferentCategory(
      GetArticlesFromDifferentCategory event,
      Emitter<RemoteArticlesState> emit) async {
    final List<String> category =
        List<String>.from(event.getArticlesParams.category ?? ["For You"]);
    emit(RemoteArticlesLoading());
    final dataState = await getArticlesUseCase(params: event.getArticlesParams);

    if (dataState is DataSuccess) {
      if (dataState.data?.articleList != null) {
        emit(RemoteArticlesFetchedFromDifferentCategory(
            dataState.data ?? ArticleListEntity(), category));
      } else {
        final dataState =
            await getLatestArticlesUseCase(params: event.getArticlesParams);
        if (dataState is DataSuccess) {
          if (dataState.data?.articleList != null) {
            emit(RemoteArticlesFetched(
                dataState.data ?? ArticleListEntity(), category));
          }
        }
        if (dataState is DataFailed) {
          emit(RemoteArticlesError(dataState.error!));
        }
      }
    }
    if (dataState is DataFailed) {
      final dataState =
          await getLatestArticlesUseCase(params: event.getArticlesParams);
      if (dataState is DataSuccess) {
        if (dataState.data?.articleList != null) {
          emit(RemoteArticlesFetched(
              dataState.data ?? ArticleListEntity(), category));
        }
      }
      if (dataState is DataFailed) {
        emit(RemoteArticlesError(dataState.error!));
      }
    }
  }

  void onGetSimilarArticles(
      GetSimilarArticles event, Emitter<RemoteArticlesState> emit) async {
    emit(RemoteSimilarArticlesLoading());

    final dataState = await getSimilarArticlesUseCase(params: event.params);

    if (dataState is DataSuccess) {
      if (dataState.data?.articleList != null) {
        emit(RemoteSimilarArticlesFetched(
            dataState.data ?? ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onGetClusteredArticles(
      GetClusteredArticles event, Emitter<RemoteArticlesState> emit) async {
    emit(RemoteClusteredArticlesLoading());

    final dataState = await getClusteredArticlesUseCase(params: event.article);

    if (dataState is DataSuccess) {
      if (dataState.data?.articleList != null) {
        emit(RemoteClusteredArticlesFetched(
            dataState.data ?? ArticleListEntity()));
      }
    }
    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onMarkArticleAsSeen(
      MarkArticleAsSeen event, Emitter<RemoteArticlesState> emit) async {
    await markArticlesAsSeenUseCase.call(params: event.articleId);
  }
}
