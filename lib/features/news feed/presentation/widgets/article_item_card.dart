import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/core/util/article_band.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/pages/music_player_bottom_sheet.dart';
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
  final DrummerEntity? drummerEntity;
  ArticleItemCard(
      {super.key,
      required this.article,
      required this.bands,
      required this.drummerEntity});

  @override
  Widget build(BuildContext context) {
    double height = 350;
    double curve = 20;
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.medium);
        context
            .read<UserActivityBloc>()
            .add(RecordUserActivity(UserActivityEntity(
              type: INTERACTION_OPENED,
              weight: WEIGHT_OPENED,
              articleId: article.articleId!,
              embedding: article.embedding??VectorValue([]),
            )));
        showModalBottomSheet(
          context: context,
          builder: (_) => BlocProvider.value(
              value:
                  context.read<UserActivityBloc>(), // Provide the existing bloc
              child: ReadArticlePage(
                article: article,
                bands: bands,
                drummerEntity: drummerEntity,
              )),
          isScrollControlled: true, // For making the sheet extendable
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(curve),
            color: DrummTheme.primaryItemColor(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      (article.meta ?? ""),
                      minFontSize: 12,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: DRUMM_FONT_FAMILY,
                        color: DrummTheme.primaryTextColor(context),
                      ),
                    ),
                    AutoSizeText(
                      " • ",
                      minFontSize: 12,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: DRUMM_FONT_FAMILY,
                        color:
                            DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                    AutoSizeText(
                      article.category ?? "",
                      minFontSize: 12,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: DRUMM_FONT_FAMILY,
                        color:
                            DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl ?? "",
                  height: height,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      DrummConstants.DRUMM_LOGO_ICON,
                      color:
                          DrummTheme.primaryTextColor(context).withAlpha(150),
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    );
                  },
                  placeholder: (context, url) {
                    return Container(
                        color: DrummTheme.primaryItemColor(context)
                            .withAlpha(100));
                  },
                ),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black,
                        Colors.transparent
                      ])),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  height: height,
                  alignment: Alignment.bottomCenter,
                  child: AutoSizeText(
                    (article.title ?? ""),
                    minFontSize: 18,
                    softWrap: true,
                    maxLines: (article.title ?? "").length < 30 ? 1 : 2,
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors
                            .white, //DrummTheme.primaryTextColor(context),
                        fontWeight: FontWeight.w900,
                        overflow: TextOverflow.clip),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
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
                      color: DrummTheme.primaryTextColor(context),
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
              ),
            ),
            SizedBox(
              height: 12,
            ),
            GestureDetector(
              onTap: () {
                Vibrate.feedback(FeedbackType.impact);
                context
                    .read<UserActivityBloc>()
                    .add(RecordUserActivity(UserActivityEntity(
                      type: INTERACTION_OPENED,
                      weight: WEIGHT_OPENED,
                      articleId: article.articleId!,
                      embedding: article.embedding!,
                    )));

                List<Object> parameters = [];
                parameters.add(article);
                parameters.add(drummerEntity ?? DrummerEntity());
                parameters.add(bands);

                context.push(
                  SCREEN_BOTTOM_CONVERSATION,
                  extra: parameters,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: DrummTheme.primarySelectedItemColor(context)
                      .withAlpha(15),
                  borderRadius: BorderRadius.circular(curve),
                ),
                child: Row(
                  children: [
                    ArticleDrummButton(
                      article: article,
                      bands: bands,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      child: AutoSizeText(
                        (article.question ?? "").trim(),
                        minFontSize: 12,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: DRUMM_FONT_FAMILY,
                          color: DrummTheme.primaryTextColor(
                              context), //.withAlpha(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
