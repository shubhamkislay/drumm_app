import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class MarkArticlesAsSeenUseCase
    implements UseCase<void, String> {
  final ArticleRepository articleRepository;
  MarkArticlesAsSeenUseCase(this.articleRepository);

  @override
  Future<void> call({String? params}) async {
    await articleRepository.markArticleAsSeen(params!);
  }
}