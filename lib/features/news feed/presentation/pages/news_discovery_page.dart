import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsDiscoveryPage extends StatelessWidget {
  const NewsDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<ArticleEntity> articleList = [];
    var lastDocument;
    return BlocProvider<RemoteArticlesBloc>(
      create: (providerContext) => s1()..add(GetArticles(GetArticlesParams(category: ["For You"]))),
      child: Scaffold(
        body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            String result = "News Discovery";
            if(state is RemoteArticlesLoading) {
              result = "Fetching articles...";
            } if(state is RemoteArticlesFetched) {
              List<ArticleEntity> fArticleList = state.articleEntityList?.articleList??[];
              articleList.addAll(fArticleList);
              lastDocument = state.articleEntityList?.lastDocument!;
              return Column(
                children: [
                  Center(
                    child: Text(result),
                  ),
                  Expanded(
                    child: ArticleListWidget(
                      articles: articleList,
                      loadMoreArticles: () {
                        // Dispatch event to fetch more articles
                        context.read<RemoteArticlesBloc>().add(
                          GetArticles(GetArticlesParams(
                            category: ["For You"],
                            lastDocument: lastDocument,
                          )),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Center(
                  child: Text(result),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
