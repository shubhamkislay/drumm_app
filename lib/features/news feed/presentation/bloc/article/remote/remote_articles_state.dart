import 'package:dio/dio.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteArticlesState extends Equatable{
  final List<ArticleEntity> ? articleEntityList;
  final DioException ? error;

  const RemoteArticlesState({this.articleEntityList, this.error});

  @override
  List<Object> get props => [articleEntityList!, error!];
}

class RemoteArticlesLoading extends RemoteArticlesState{
  const RemoteArticlesLoading();
}

class RemoteArticlesFetched extends RemoteArticlesState{
  const RemoteArticlesFetched(List<ArticleEntity> articleEntityList) : super(articleEntityList: articleEntityList);
}

class RemoteArticlesError extends RemoteArticlesState{
  const RemoteArticlesError(DioException error) : super(error: error);
}
