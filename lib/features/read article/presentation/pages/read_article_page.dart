import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/util/article_band.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/article_sources_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/close_dialog_button.dart';
import 'package:drumm_app/features/start%20conversation/presentation/pages/bottom_start_conversation_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/share_button.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/similar_articles_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/start_drumm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';

class ReadArticlePage extends StatelessWidget {
  final ArticleEntity article;
  final List<BandEntity> bands;
  const ReadArticlePage({super.key, required this.article, required this.bands});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        shouldCloseOnMinExtent: true,
        snap: false,
        snapAnimationDuration: Duration(milliseconds: 100),
        initialChildSize: 1,
        minChildSize: 0.9,
        maxChildSize: 1,
        builder: (BuildContext context, ScrollController scrollController) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: DrummTheme.primaryItemColor(context),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: scrollController,
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.imageUrl ?? "",
                          height: 375,
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Container(
                                color:
                                    DrummTheme.primaryItemBackground(context));
                          },
                          placeholder: (context, url) {
                            return Container(
                                color:
                                    DrummTheme.primaryItemBackground(context));
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
                                maxLines: (article.question ?? "").length < 30
                                    ? 1
                                    : 2,
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
                                height: 8,
                              ),
                              ArticleSourcesWidget(article: article),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                article.summary ?? "",
                                style: TextStyle(
                                  height: 1.75,
                                  fontSize: 16,
                                  color: DrummTheme.primaryTextColor(context),
                                  fontFamily: DRUMM_FONT_FAMILY,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              SimilarArticlesWidget(
                                  params: GetSimilarArticlesParams(
                                      article: article,
                                      embedding: article.embedding), bands: bands,),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 200,
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 64),
                        child: StartDrummButton(article: article, onPressed: () {
                          Vibrate.feedback(FeedbackType.impact);
                          context.push(SCREEN_BOTTOM_CONVERSATION,extra: ArticleBands(article: article,bands: bands));
                        },)),

                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CloseDialogButton(),
                        ArticleShareButton(article: article),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
