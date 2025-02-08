import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_drumm_button.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_card.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ArticleItemLoadingCard extends StatelessWidget {
  ArticleItemLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Shimmer(
          color: DrummTheme.drummPrimaryColor,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16,),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: DrummTheme.primaryItemColor(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(
                  height:12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 26,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 26,
                    width: 250,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 18,
                    width: 100,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 250,
                    color: DrummTheme.primaryItemBackground(context)),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
