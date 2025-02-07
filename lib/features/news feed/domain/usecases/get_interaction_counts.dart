import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class GetInteractionCountsUseCase
    implements UseCase<int, void> {
  final ArticleRepository articleRepository;

  GetInteractionCountsUseCase(this.articleRepository);

  @override
  Future<int> call({void params}) async {
    try {
      int count = await articleRepository.getInteractionsCount();
      return count;
    }  catch (e) {
      return 0;
    }
  }
}
