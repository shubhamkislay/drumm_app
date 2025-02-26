import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
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
  final List<ArticleEntity> articles;
  final List<BandEntity> bands;
  final DrummerEntity? drummerEntity;

  const ArticleListWidget({
    super.key,
    required this.articles,
    required this.bands,
    required this.drummerEntity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
      return Container(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          itemCount: (state is RemoteArticlesLoadingMoreArticles ||
                  state is RemoteArticlesLoading)
              ? articles.length + 5
              : articles.length,
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            if (state is RemoteArticlesLoadingMoreArticles ||
                state is RemoteArticlesLoading) {
              if (index > articles.length - 1) {
                return ArticleItemLoadingCard();
              }
            }
            final article = articles[index];
            return ArticleItemCard(
              article: article,
              bands: bands,
              drummerEntity: drummerEntity,
            );
          },
        ),
      );
    });
  }
}
