import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/domain/usecases/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class GetArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, String> {
  final ArticleRepository articleRepository;

  GetArticlesUseCase(this.articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({String? params}) async {
    try {
      List<String> category = [];
      if (params == "For You") {
        var bandDataset = await articleRepository.getBandsCategoryList();
        if (bandDataset is DataSuccess) {
          category.addAll(bandDataset.data!);
        }
      }else{
        category.add(params!);
      }
      var articleDataState = await articleRepository.getArticles(category);
      if (articleDataState is DataSuccess) {
        return DataSuccess(articleDataState.data!);
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message:
                "Failed to fetch articles because ${articleDataState.error!.message}"));
      }
    } on DioException catch (e) {
      return DataFailed(
          DioException(requestOptions: RequestOptions(), message: e.message));
    }
  }
}
