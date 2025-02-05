import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/domain/repository/user_activity_repository.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';

class RecordUserActivityUseCase
    implements UseCase<void, UserActivityEntity> {
  final UserActivityRepository userActivityRepository;

  RecordUserActivityUseCase(this.userActivityRepository);

  @override
  Future<void> call({UserActivityEntity? params}) async {
        userActivityRepository.recordUserActivity(params!);
  }
}
