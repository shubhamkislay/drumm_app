import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_card.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleListWidget extends StatelessWidget {
  final List<ArticleEntity> articles;
  final VoidCallback loadMoreArticles;

  const ArticleListWidget({
    super.key,
    required this.articles,
    required this.loadMoreArticles,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification &&
              scrollNotification.metrics.extentAfter < 500 &&
              state is! RemoteArticlesLoadingMoreArticles && state is! RemoteArticlesLoading && state is! RemoteArticlesError) {
            loadMoreArticles();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: (state is RemoteArticlesLoadingMoreArticles || state is  RemoteArticlesLoading) ? articles.length + 5 : articles.length,
          itemBuilder: (context, index) {
            if(state is RemoteArticlesLoadingMoreArticles || state is RemoteArticlesLoading){
              if(index > articles.length-1) {
                return ArticleItemLoadingCard();
              }
            }
            final article = articles[index];
            return ArticleItemCard(
              article: article,
            );
          },
        ),
      );
    });
  }
}
