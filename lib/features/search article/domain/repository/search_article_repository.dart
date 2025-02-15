import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

abstract class SearchArticleRepository {
  Future<List<ArticleEntity>> searchArticles(String query);
}
