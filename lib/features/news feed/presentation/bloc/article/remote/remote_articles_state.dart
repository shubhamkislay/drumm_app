import 'package:dio/dio.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteArticlesState extends Equatable{
  final ArticleListEntity ? articleEntityList;
  final List<String> ? category;
  final DioException ? error;
  final int ? interactions;

  const RemoteArticlesState({this.articleEntityList, this.error, this.interactions, this.category});

  @override
  List<Object> get props => [articleEntityList!,category??["For You"],interactions??0,error??DioException(requestOptions: RequestOptions())];
}

class RemoteArticlesLoading extends RemoteArticlesState{
  const RemoteArticlesLoading();
}

class RemoteArticlesFetched extends RemoteArticlesState{
  const RemoteArticlesFetched(ArticleListEntity articleEntityList, List<String> category) : super(articleEntityList: articleEntityList,category: category);
}

class RemoteArticlesFetchedFromDifferentCategory extends RemoteArticlesState{
  const RemoteArticlesFetchedFromDifferentCategory(ArticleListEntity articleEntityList, List<String> category) : super(articleEntityList: articleEntityList,category: category);
}

class RemoteArticlesLoadingMoreArticles extends RemoteArticlesState{
  const RemoteArticlesLoadingMoreArticles();
}

class RemoteArticlesError extends RemoteArticlesState{
  const RemoteArticlesError(DioException error) : super(error: error);
}

class RemoteClusteredArticlesLoading extends RemoteArticlesState{
  const RemoteClusteredArticlesLoading();
}

class GeneratingRecommendation extends RemoteArticlesState{
  const GeneratingRecommendation(ArticleListEntity articleEntityList, List<String> category) : super(articleEntityList: articleEntityList,category: category);
}

class GeneratedRecommendationArticle extends RemoteArticlesState{
  const GeneratedRecommendationArticle();
}

class GeneratedRecommendationArticleApplied extends RemoteArticlesState{
  const GeneratedRecommendationArticleApplied(ArticleListEntity articleEntityList, List<String> category) : super(articleEntityList: articleEntityList,category: category);
}

class NoNewRecommendations extends RemoteArticlesState{
  const NoNewRecommendations();
}

class InteractToGenerateRecommendation extends RemoteArticlesState{
  const InteractToGenerateRecommendation(int interactions,List<String> category) : super(interactions : interactions,category: category);
}

class RemoteSimilarArticlesLoading extends RemoteArticlesState{
  const RemoteSimilarArticlesLoading();
}

class RemoteClusteredArticlesFetched extends RemoteArticlesState{
  const RemoteClusteredArticlesFetched(ArticleListEntity articleEntityList) : super(articleEntityList: articleEntityList);
}

class RemoteSimilarArticlesFetched extends RemoteArticlesState{
  const RemoteSimilarArticlesFetched(ArticleListEntity articleEntityList) : super(articleEntityList: articleEntityList);
}
