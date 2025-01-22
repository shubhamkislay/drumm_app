import 'package:flutter/material.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

class ArticleListWidget extends StatelessWidget {
  final List<ArticleEntity> articles;
  final VoidCallback loadMoreArticles;

  const ArticleListWidget({
    Key? key,
    required this.articles,
    required this.loadMoreArticles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter == 0) {
          // Trigger pagination when reaching the end of the list
          loadMoreArticles();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article.meta ?? 'No Title'),
            subtitle: Text(article.summary ?? 'No Summary'),
            onTap: () {
              // Handle article tap (e.g., navigate to details)
            },
          );
        },
      ),
    );
  }
}
