import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_card.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification &&
            scrollNotification.metrics.extentAfter < 500) {
          loadMoreArticles();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleItemCard(article: article,);
        },
      ),
    );
  }
}
