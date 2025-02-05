import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_drumm_button.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';

class ArticleItemCard extends StatelessWidget {
  ArticleEntity article;
  final List<BandEntity> bands;
  ArticleItemCard({super.key, required this.article, required this.bands});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.medium);
        context
            .read<UserActivityBloc>()
            .add(RecordUserActivity(UserActivityEntity(
          type: INTERACTION_OPENED,
          weight: WEIGHT_OPENED,
          articleId: article.articleId!,
          embedding: article.embedding!,
        )));
        showModalBottomSheet(
          context: context,
          builder: (_) => BlocProvider.value(
          value: context.read<UserActivityBloc>(), // Provide the existing bloc
          child: ReadArticlePage(article: article, bands: bands)),
          isScrollControlled: true, // For making the sheet extendable
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText(
                  article.category ?? "",
                  minFontSize: 12,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: DRUMM_FONT_FAMILY,
                    color: DrummTheme.primaryTextColor(context).withOpacity(0.5),
                  ),
                ),
                ArticleDrummButton(article: article,bands: bands,),
              ],
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: DRUMM_FONT_FAMILY,
                color: DrummTheme.primaryTextColor(context).withOpacity(0.75),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl ?? "",
                height: 250,
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
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Text(
                  (article.relatedImageUrls ?? []).isNotEmpty
                      ? "${(article.relatedImageUrls ?? []).length + 1} sources"
                      : article.source ?? "",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: DRUMM_FONT_FAMILY,
                    color:
                        DrummTheme.primaryTextColor(context).withOpacity(0.5),
                  ),
                ),
                Text(
                  " • ",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: DRUMM_FONT_FAMILY,
                    fontWeight: FontWeight.bold,
                    color:
                        DrummTheme.primaryTextColor(context).withOpacity(0.5),
                  ),
                ),
                InstagramDateTimeWidget(
                    publishedAt: article.publishedAt.toString())
              ],
            )
          ],
        ),
      ),
    );
  }
}
