import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/search%20article/data/data_sources/search_article_service.dart';
import 'package:drumm_app/features/search%20article/domain/repository/search_article_repository.dart';

class SearchArticleRepositoryImpl implements SearchArticleRepository {
  final SearchArticleService service;

  SearchArticleRepositoryImpl({required this.service});

  @override
  Future<List<ArticleEntity>> searchArticles(String query) async {
    final articleModels = await service.searchArticles(query);
    return articleModels;
  }
}
