import 'package:cloud_firestore_platform_interface/src/vector_value.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/data_sources/remote/article_service.dart';
import 'package:drumm_app/features/news%20feed/data/models/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class ArticleRespositoryImpl implements ArticleRepository {
  ArticleService articleService;

  ArticleRespositoryImpl(this.articleService);

  @override
  Future<DataState<List<String>>> getBandsCategoryList() {
    return articleService.getBandsCategoryList();
  }

  @override
  Future<DataState<ArticleListEntity>> getArticles(
      GetArticlesParams getArticlesParams) {
    return articleService.getArticles(getArticlesParams);
  }

  @override
  Future<DataState<ArticleListEntity>> getClusteredArticles(
      ArticleEntity article) {
    return articleService.getClusteredArticles(article);
  }

  @override
  Future<DataState<ArticleListEntity>> getSimilarArticles(
      GetSimilarArticlesParams params) {
    return articleService.getSimilarArticles(params);
  }

  @override
  Future<DataState<ArticleListEntity>> performVectorSearch(GetArticlesParams params) {
    return articleService.performVectorSearch(params);
  }

  @override
  Future<DataState<ArticleListEntity>> getLatestArticles(GetArticlesParams getArticlesParams) {
    return articleService.getLatestArticles(getArticlesParams);
  }

  @override
  Future<int> getInteractionsCount() {
    return articleService.getInteractionsCount();
  }

  @override
  Future<DataState<bool>> generateAndLoadRecommendedArticles(GetArticlesParams params) {
    return articleService.generateAndLoadRecommendedArticles(params);
  }

  @override
  Future<DataState<bool>> vectorSearchAndLoadRecommendedArticles(GetArticlesParams params) {
    return articleService.vectorSearchAndLoadRecommendedArticles(params);
  }
}
