import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_loading_card.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_list_widget.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/band_selection_list.dart';
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
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BandSelectionList(
                onSelect: (bandEntity) {
                  Vibrate.feedback(FeedbackType.selection);
                  lastDocument = null;
                  if (selectedBandId != bandEntity.bandId) {
                    selectedBandId = bandEntity.bandId ?? "For You";
                    print("selectedBandId: ${selectedBandId}");
                    context.read<RemoteArticlesBloc>().add(
                          GetArticlesFromDifferentCategory(GetArticlesParams(
                            category: [selectedBandId],
                            lastDocument: lastDocument,
                          )),
                        );
                  }
                },
              ),
              Expanded(
                child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                  builder: (context, state) {
                    if (state is RemoteArticlesLoading) {
                      articleList.clear();
                    } else if (state is! RemoteArticlesError) {
                      List<ArticleEntity> fArticleList =
                          state.articleEntityList?.articleList ?? [];
                      if (state is RemoteArticlesFetchedFromDifferentCategory)
                        articleList.clear();
                      articleList.addAll(fArticleList);
                      lastDocument = state.articleEntityList?.lastDocument!;
                    } else {
                      if (articleList.isEmpty)
                        return Center(child: Text("${state.error?.message}"));
                    }

                    return ArticleListWidget(
                      articles: articleList,
                      loadMoreArticles: () {
                        context.read<RemoteArticlesBloc>().add(
                              GetArticles(GetArticlesParams(
                                category: [selectedBandId],
                                lastDocument: lastDocument,
                              )),
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
