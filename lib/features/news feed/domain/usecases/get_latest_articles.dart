import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class GetLatestArticlesUseCase
    implements UseCase<DataState<ArticleListEntity>, GetArticlesParams> {
  final ArticleRepository articleRepository;

  GetLatestArticlesUseCase(this.articleRepository);

  @override
  Future<DataState<ArticleListEntity>> call({GetArticlesParams? params}) async {
    try {
      if (params!=null && params.category!=null && params.category!.isNotEmpty && params.category!.elementAt(0) == "For You") {
        var bandDataset = await articleRepository.getBandsCategoryList();
        if (bandDataset is DataSuccess) {
          params.category?.clear();
          params.category?.addAll(bandDataset.data!);
        }
      }
      var articleDataState = await articleRepository.getLatestArticles(params!);
      if (articleDataState is DataSuccess) {

        return DataSuccess(articleDataState.data!);
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message:articleDataState.error?.message));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
