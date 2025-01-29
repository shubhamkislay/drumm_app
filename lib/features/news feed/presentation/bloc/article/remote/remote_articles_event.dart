import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';

abstract class RemoteArticlesEvent{
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent{
  final GetArticlesParams getArticlesParams;
  const GetArticles(this.getArticlesParams);
}

class GetArticlesFromDifferentCategory extends RemoteArticlesEvent{
  final GetArticlesParams getArticlesParams;
  const GetArticlesFromDifferentCategory(this.getArticlesParams);
}