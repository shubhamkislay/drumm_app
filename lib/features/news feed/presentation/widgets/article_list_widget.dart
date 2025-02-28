import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_card.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ArticleListWidget extends StatelessWidget {

  const ArticleListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<ArticleEntity> articleList = [];
    List<BandEntity> bands = [];
    DrummerEntity drummerEntity = DrummerEntity();
    return BlocListener<RemoteDrummerBloc, RemoteDrummerState>(
      listener: (context, drummerState) {
        if(drummerState is RefreshedDrummer||drummerState is RemoteDrummerLoading){
          articleList.clear();
        }
      },
      child: BlocListener<RemoteBandsBloc, RemoteBandsState>(
        listener: (context, bandState) {
          bands = bandState.bands??[];
        },
        child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
            builder: (context, articleState) {




              if (articleState is RemoteArticlesLoading) {
                //print("The article state is loading ${articleList.length}");
                articleList.clear();
              } else if (articleState
              is! RemoteArticlesError) {
                List<ArticleEntity> fArticleList = [];
                if (articleState is RemoteArticlesFetched ||
                    articleState
                    is RemoteArticlesFetchedFromDifferentCategory ||
                    articleState
                    is GeneratingRecommendation ||
                    articleState
                    is GeneratedRecommendationArticleApplied ||
                    articleState
                    is InteractToGenerateRecommendation) {
                  if (articleState.articleEntityList !=
                      null) {
                    fArticleList = articleState
                        .articleEntityList
                        ?.articleList ??
                        [];
                  }

                  //print("The article state is ${articleState}");
                  if (articleState
                  is RemoteArticlesFetchedFromDifferentCategory ||
                      articleState
                      is GeneratedRecommendationArticleApplied) {
                    articleList.clear();
                  }
                  articleList.addAll(fArticleList);

                  if(articleState is RemoteArticlesFetched){
                    //print("This is being called with article list size ${articleList.length}");
                  }
                }
              } else {
                if (articleList.isEmpty) {
                  return SizedBox(
                      height: 500,
                      child: Center(
                          child: Text(
                              "${articleState.error?.message}")));
                }
              }

              return Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ListView.builder(
                  itemCount: (articleState is RemoteArticlesLoadingMoreArticles ||
                      articleState is RemoteArticlesLoading)
                      ? articleList.length + 5
                      : articleList.length,
                  shrinkWrap: true,
                  primary: false,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    ////print("Length of the article is ${articles.length}");
                    if (articleState is RemoteArticlesLoadingMoreArticles ||
                        articleState is RemoteArticlesLoading) {
                      if (index > articleList.length - 1) {
                        return ArticleItemLoadingCard();
                      }
                    }
                    final article = articleList[index];
                    return ArticleItemCard(
                      article: article,
                      bands: bands??[],
                      drummerEntity: drummerEntity,
                    );
                  },
                ),
              );
            })
      ),
    );
  }
}
