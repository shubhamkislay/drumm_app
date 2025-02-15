import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/search%20article/domain/repository/search_article_repository.dart';

class SearchArticlesUseCase {
  final SearchArticleRepository repository;

  SearchArticlesUseCase(this.repository);

  Future<List<ArticleEntity>> call(String query) async {
    return await repository.searchArticles(query);
  }
}
