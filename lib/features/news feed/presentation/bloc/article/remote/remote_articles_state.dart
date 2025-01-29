import 'package:dio/dio.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteArticlesState extends Equatable{
  final ArticleListEntity ? articleEntityList;
  final DioException ? error;

  const RemoteArticlesState({this.articleEntityList, this.error});

  @override
  List<Object> get props => [articleEntityList!,error??DioException(requestOptions: RequestOptions())];
}

class RemoteArticlesLoading extends RemoteArticlesState{
  const RemoteArticlesLoading();
}

class RemoteArticlesFetched extends RemoteArticlesState{
  const RemoteArticlesFetched(ArticleListEntity articleEntityList) : super(articleEntityList: articleEntityList);
}

class RemoteArticlesFetchedFromDifferentCategory extends RemoteArticlesState{
  const RemoteArticlesFetchedFromDifferentCategory(ArticleListEntity articleEntityList) : super(articleEntityList: articleEntityList);
}

class RemoteArticlesLoadingMoreArticles extends RemoteArticlesState{
  const RemoteArticlesLoadingMoreArticles();
}

class RemoteArticlesError extends RemoteArticlesState{
  const RemoteArticlesError(DioException error) : super(error: error);
}
