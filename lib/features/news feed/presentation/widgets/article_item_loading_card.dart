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
    double curve = 16;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: Shimmer(
          color: DrummTheme.drummPrimaryColor,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16,),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(curve),
                color: DrummTheme.primaryItemColor(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(curve)),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),

                Container(
                  height: 250,
                    margin: EdgeInsets.symmetric(horizontal: 12),

                  decoration: BoxDecoration(
                      color: DrummTheme.primaryItemBackground(context),
                    borderRadius: BorderRadius.circular(curve)
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 22,
                    width: 300,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(curve)),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 22,
                    width: 300,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(curve)),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 22,
                    width: 100,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(curve)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 42,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemBackground(context),
                        borderRadius: BorderRadius.circular(curve)),
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
