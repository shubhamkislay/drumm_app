import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';

class ArticleItemCard extends StatelessWidget {
  ArticleEntity article;
  ArticleItemCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: DrummTheme.primaryItemColor(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AutoSizeText(
            article.question ?? "",
            minFontSize: 18,
            maxLines: (article.question ?? "").length<30 ?1:2,
            style: TextStyle(
                fontSize: 26,
                color: DrummTheme.primaryTextColor(context),
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip),
          ),
          AutoSizeText(
            article.meta ?? article.title ?? "",
            minFontSize: 12,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color: DrummTheme.primaryTextColor(context),
            ),
          ),
          SizedBox(height: 16,),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: article.imageUrl ?? "",
              height: 250,
              width: double.maxFinite,
              fit: BoxFit.cover,

              errorWidget: (context, url, error) {
                return Container(color: Colors.grey.shade900);
              },
            ),
          ),
          SizedBox(height: 12,),
          Row(
            children: [
              Text(
                (article.relatedImageUrls??[]).isNotEmpty ? "${(article.relatedImageUrls??[]).length+1} sources":
                article.source ??"",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: DrummTheme.primaryTextColor(context),
                ),
              ),
              Text(" • "),
              InstagramDateTimeWidget(publishedAt: article.publishedAt.toString())
            ],
          )
        ],
      ),
    );
  }
}
