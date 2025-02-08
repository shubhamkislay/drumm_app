import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class GenerateAndLoadRecommendedArticlesUseCase
    implements UseCase<DataState<bool>, GetArticlesParams> {
  final ArticleRepository articleRepository;

  GenerateAndLoadRecommendedArticlesUseCase(this.articleRepository);

  @override
  Future<DataState<bool>> call({GetArticlesParams? params}) async {
    try {
      var articleDataState = await articleRepository.generateAndLoadRecommendedArticles(params!);
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
