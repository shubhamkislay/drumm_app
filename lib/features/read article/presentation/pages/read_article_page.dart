import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        child: Stack(
          children: [
            Column(
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl ?? "",
                  height: 300,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Container(
                        color: DrummTheme.primaryItemBackground(context));
                  },
                  placeholder: (context, url) {
                    return Container(
                        color: DrummTheme.primaryItemBackground(context));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                        article.category ?? "",
                        minFontSize: 12,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: DRUMM_FONT_FAMILY,
                          color: DrummTheme.primaryTextColor(context)
                              .withOpacity(0.5),
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      AutoSizeText(
                        article.question ?? "",
                        minFontSize: 18,
                        maxLines: (article.question ?? "").length < 30 ? 1 : 2,
                        style: TextStyle(
                            fontSize: 26,
                            color: DrummTheme.primaryTextColor(context),
                            fontFamily: DRUMM_FONT_FAMILY,
                            fontWeight: FontWeight.w900,
                            overflow: TextOverflow.clip),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      AutoSizeText(
                        article.meta ?? article.title ?? "",
                        minFontSize: 12,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          color: DrummTheme.primaryTextColor(context),
                          fontFamily: DRUMM_FONT_FAMILY,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        article.summary ?? "",
                        style: TextStyle(
                          height: 1.75,
                          fontSize: 16,
                          color: DrummTheme.primaryTextColor(context),
                          fontFamily: DRUMM_FONT_FAMILY,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
