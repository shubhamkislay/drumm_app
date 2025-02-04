import 'dart:math';

import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification &&
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
        child: BlocBuilder<RemoteBandsBloc,RemoteBandsState>(
          builder: (BuildContext context, bandState) { return CustomScrollView(
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
                            selectedBandId = bandEntity.bandId ?? "For You";
                            context.read<RemoteArticlesBloc>().add(
                              GetArticlesFromDifferentCategory(
                                GetArticlesParams(
                                  category: [selectedBandId],
                                  lastDocument: lastDocument,
                                ),
                              ),
                            );
                          }
                        }, bands: bandState.bands??[], state: bandState,
                      ),
                    )),
                flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DrummTheme.primaryItemBackground(context),
                            DrummTheme.primaryItemBackground(context).withOpacity(0.75),
                            DrummTheme.primaryItemBackground(context).withOpacity(0.0),
                          ],
                        )),
                    child: FlexibleSpaceBar(
                      collapseMode: CollapseMode.none,
                      background: Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(left: 12, bottom: 64,right: 12),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discover",
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: DRUMM_FONT_FAMILY,
                                color: DrummTheme.primaryTextColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            SearchButton(
                              onPressed: (){

                              },
                            ),
                            SizedBox(width: 8,),
                            ProfileImageIcon()
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
              SliverToBoxAdapter(
                child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                  builder: (context, state) {
                    remoteState = state;
                    if (state is RemoteArticlesLoading) {
                      articleList.clear();
                    } else if (state is! RemoteArticlesError) {
                      List<ArticleEntity> fArticleList =
                          state.articleEntityList?.articleList ?? [];
                      if (state is RemoteArticlesFetchedFromDifferentCategory) {
                        articleList.clear();
                      }
                      articleList.addAll(fArticleList);
                      lastDocument = state.articleEntityList?.lastDocument!;
                    } else {
                      if (articleList.isEmpty) {
                        return SizedBox(
                            height: 500,
                            child:
                            Center(child: Text("${state.error?.message}")));
                      }
                    }

                    return Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ArticleListWidget(
                        articles: articleList,
                        bands: bandState.bands??[],
                      ),
                    );
                  },
                ),
              )
            ],
          ); },
        ),
      ),
    );
  }
}
