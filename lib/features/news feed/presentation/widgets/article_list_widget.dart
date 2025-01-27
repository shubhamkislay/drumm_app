import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
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
          return articleItem(article, context);
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

  Widget articleItem(ArticleEntity article, BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          InstagramDateTimeWidget(publishedAt: article.publishedAt.toString()),
          Text(article.question??"No Question",style: DrummTheme().getTheme(context).textTheme.headlineLarge,)
        ],
      ),
    );
  }

}
