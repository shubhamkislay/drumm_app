import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

abstract class ArticleRepository{

  Future<DataState<List<ArticleEntity>>> getArticles(List<String> category);
  Future<DataState<List<String>>> getBandsCategoryList();

}