import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';

abstract class ArticleRepository {
  Future<DataState<ArticleListEntity>> getArticles(
      GetArticlesParams getArticlesParams);
  Future<DataState<List<String>>> getBandsCategoryList();
  Future<DataState<ArticleListEntity>> getClusteredArticles(
      ArticleEntity article);
  Future<DataState<ArticleListEntity>> getSimilarArticles(
      GetSimilarArticlesParams params);
}
