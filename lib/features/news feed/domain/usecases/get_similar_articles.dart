import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class GetSimilarArticlesUseCase
    implements UseCase<DataState<ArticleListEntity>, GetSimilarArticlesParams> {
  final ArticleRepository articleRepository;

  GetSimilarArticlesUseCase(this.articleRepository);

  @override
  Future<DataState<ArticleListEntity>> call({GetSimilarArticlesParams ? params}) async {
    try {
      var articleDataState = await articleRepository.getSimilarArticles(params!);
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
