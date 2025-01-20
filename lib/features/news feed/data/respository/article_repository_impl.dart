import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/data_sources/remote/article_service.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class ArticleRespositoryImpl implements ArticleRepository{

  ArticleService articleService;

  ArticleRespositoryImpl(this.articleService);

  @override
  Future<DataState<List<ArticleModel>>> getArticles(List<String> category) {
    return articleService.getArticles(category);
  }

  @override
  Future<DataState<List<String>>> getBandsCategoryList() {
    return articleService.getBandsCategoryList();
  }

}