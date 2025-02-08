import 'dart:math';

import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_loading_card.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_list_widget.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/band_selection_list.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/profile_image_icon.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/safe_area_persistent_header_delegate.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/search_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class NewsDiscoveryPage extends StatelessWidget {
  const NewsDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<ArticleEntity> articleList = [];
    var lastDocument;
    String selectedBandId = "For You";
    RemoteArticlesState remoteState = RemoteArticlesLoading();
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<RemoteDrummerBloc, RemoteDrummerState>(
          builder: (context, drummerState) {
        if (drummerState is RemoteDrummerDone) {
          context.read<RemoteArticlesBloc>().add(GetRecommendedArticles(
              GetArticlesParams(
                  category: ["For You"],
                  drummerEntity: drummerState.drummerEntity)));
        }
        return BlocBuilder<RemoteBandsBloc, RemoteBandsState>(
          builder: (BuildContext context, bandState) {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.axisDirection ==
                        AxisDirection.down &&
                    scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.metrics.extentAfter < 500 &&
                    remoteState is! RemoteArticlesLoadingMoreArticles &&
                    remoteState is! RemoteArticlesLoading &&
                    remoteState is! RemoteArticlesError) {
                  context.read<RemoteArticlesBloc>().add(
                        GetArticles(GetArticlesParams(
                          category: [selectedBandId],
                          lastDocument: lastDocument,
                        )),
                      );
                }
                return false;
              },
              child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                  builder: (context, articleState) {
                return CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      bottom: PreferredSize(
                          preferredSize: Size.fromHeight(50),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 12),
                            child: BandSelectionList(
                              onSelect: (bandEntity) {
                                Vibrate.feedback(FeedbackType.selection);
                                lastDocument = null;
                                if (selectedBandId != bandEntity.bandId) {
                                  selectedBandId =
                                      bandEntity.bandId ?? "For You";
                                  context.read<RemoteArticlesBloc>().add(
                                        GetArticlesFromDifferentCategory(
                                          GetArticlesParams(
                                            category: [selectedBandId],
                                            lastDocument: lastDocument,
                                          ),
                                        ),
                                      );
                                }
                              },
                              bands: bandState.bands ?? [],
                              state: bandState,
                            ),
                          )),
                      flexibleSpace:
                          LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              DrummTheme.primaryItemBackground(context),
                              DrummTheme.primaryItemBackground(context)
                                  .withOpacity(0.75),
                              DrummTheme.primaryItemBackground(context)
                                  .withOpacity(0.0),
                            ],
                          )),
                          child: FlexibleSpaceBar(
                            collapseMode: CollapseMode.none,
                            background: Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(
                                  left: 12, bottom: 64, right: 12),
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Discover",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: DRUMM_FONT_FAMILY,
                                      color:
                                          DrummTheme.primaryTextColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  SearchButton(
                                    onPressed: () {},
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  ProfileImageIcon(state: drummerState)
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      toolbarHeight: 0,
                      collapsedHeight: 0,
                      expandedHeight: 120,
                    ),
                    if (articleState is GeneratingRecommendation)
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: Container(
                          height: 44,
                          width: double.maxFinite,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: DrummTheme.primaryItemColor(context)),
                          child: Row(
                            children: [
                              Image.asset('images/sparkles.png',
                                  color: DrummTheme.drummPrimaryColor,
                                  fit: BoxFit.contain),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Fetching news that you might be interested in...",
                                maxLines: 2,
                                style: TextStyle(
                                    color: DrummTheme.primaryTextColor(context),
                                    fontFamily: DRUMM_FONT_FAMILY,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                    if (articleState is RemoteArticlesLoading)
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: Container(
                          height: 44,
                          width: double.maxFinite,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: DrummTheme.primaryItemColor(context)),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: DrummTheme.primaryTextColor(context),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Checking what's happening around the world",
                                maxLines: 2,
                                style: TextStyle(
                                    color: DrummTheme.primaryTextColor(context),
                                    fontFamily: DRUMM_FONT_FAMILY,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                    if (articleState is InteractToGenerateRecommendation)
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: Container(
                          height: 44,
                          width: double.maxFinite,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: DrummTheme.primaryItemColor(context)),
                          child: Row(
                            children: [
                              Image.asset('images/puzzle-game.png',
                                  color: DrummTheme.drummPrimaryColor,
                                  fit: BoxFit.contain),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Check ${articleState.interactions} more articles to personalise feed",
                                maxLines: 2,
                                style: TextStyle(
                                    color: DrummTheme.primaryTextColor(context),
                                    fontFamily: DRUMM_FONT_FAMILY,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                    if (articleState is GeneratedRecommendationArticle)
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: GestureDetector(
                          onTap: () {
                            articleList.clear();
                            context.read<RemoteArticlesBloc>().add(
                              GetArticles(GetArticlesParams(
                                category: [selectedBandId],
                              )),
                            );
                          },
                          child: Container(
                            height: 44,
                            width: double.maxFinite,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            margin: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: DrummTheme.drummPrimaryColor),
                            child: Text(
                              "New Updates",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: DRUMM_FONT_FAMILY,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          remoteState = articleState;
                          if (articleState is RemoteArticlesLoading) {
                            articleList.clear();
                          } else if (articleState is! RemoteArticlesError) {
                            List<ArticleEntity> fArticleList = [];
                            if (articleState is RemoteArticlesFetched ||
                                articleState
                                    is RemoteArticlesFetchedFromDifferentCategory ||
                                articleState is GeneratingRecommendation ||
                                articleState
                                    is GeneratedRecommendationArticleApplied ||
                                articleState
                                    is InteractToGenerateRecommendation) {
                              if (articleState.articleEntityList != null) {
                                fArticleList = articleState
                                        .articleEntityList?.articleList ??
                                    [];
                              }

                              if (articleState is RemoteArticlesFetchedFromDifferentCategory ||
                                  articleState is GeneratedRecommendationArticleApplied) {
                                articleList.clear();
                              }
                              articleList.addAll(fArticleList);

                              lastDocument =
                                  articleState.articleEntityList?.lastDocument??null;
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ArticleListWidget(
                              articles: articleList,
                              bands: bandState.bands ?? [],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            );
          },
        );
      }),
    );
  }
}
