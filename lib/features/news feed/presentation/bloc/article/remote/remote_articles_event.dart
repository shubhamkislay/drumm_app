import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';

abstract class RemoteArticlesEvent{
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent{
  final GetArticlesParams getArticlesParams;
  const GetArticles(this.getArticlesParams);
}

class GetRecommendedArticles extends RemoteArticlesEvent{
  final GetArticlesParams getArticlesParams;
  const GetRecommendedArticles(this.getArticlesParams);
}

class GetArticlesFromDifferentCategory extends RemoteArticlesEvent{
  final GetArticlesParams getArticlesParams;
  const GetArticlesFromDifferentCategory(this.getArticlesParams);
}

class GetClusteredArticles extends RemoteArticlesEvent{
  final ArticleEntity article;
  const GetClusteredArticles(this.article);
}

class GetSimilarArticles extends RemoteArticlesEvent{
  final GetSimilarArticlesParams params;
  const GetSimilarArticles(this.params);
}