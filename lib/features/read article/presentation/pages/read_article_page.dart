import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';

class ReadArticlePage extends StatelessWidget {
  ArticleEntity article;
  ReadArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        color: DrummTheme.primaryItemColor(context),
        child: Center(child: Text("${article.title}")),
      ),
    );
  }
}
