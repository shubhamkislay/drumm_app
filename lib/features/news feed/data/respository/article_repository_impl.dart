import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/data_sources/remote/article_service.dart';
import 'package:drumm_app/features/news%20feed/data/models/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class ArticleRespositoryImpl implements ArticleRepository{

  ArticleService articleService;

  ArticleRespositoryImpl(this.articleService);



  @override
  Future<DataState<List<String>>> getBandsCategoryList() {
    return articleService.getBandsCategoryList();
  }

  @override
  Future<DataState<ArticleListModel>> getArticles(GetArticlesParams getArticlesParams) {
    return articleService.getArticles(getArticlesParams);
  }


}