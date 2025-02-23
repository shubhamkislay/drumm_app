import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_drumm_button.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/article_sources_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/close_dialog_button.dart';
import 'package:drumm_app/features/start%20conversation/presentation/pages/bottom_start_conversation_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/article_share_button.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/similar_articles_widget.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/start_drumm_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

class ReadArticlePage extends StatefulWidget {
  final ArticleEntity article;
  final List<BandEntity> bands;
  final DrummerEntity ? drummerEntity;
  const ReadArticlePage(
      {super.key, required this.article, required this.bands, required this.drummerEntity});

  @override
  State<ReadArticlePage> createState() => _ReadArticlePageState();
}

class _ReadArticlePageState extends State<ReadArticlePage> {
  Timer? _timer;
  bool _isTriggered = false;

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'ReadArticlePage',
      parameters: <String, Object>{
        'category': widget.article.category??"",
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
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
            borderRadius: BorderRadius.circular(16),
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
                          imageUrl: widget.article.imageUrl ?? "",
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
                              Row(
                                children: [
                                  AutoSizeText(
                                    widget.article.meta ?? "",
                                    minFontSize: 12,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: DRUMM_FONT_FAMILY,
                                      color: DrummTheme.drummPrimaryColor,
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
                                      color: DrummTheme.primaryTextColor(context).withAlpha(100),
                                    ),
                                  ),
                                  AutoSizeText(
                                    widget.article.category ?? "",
                                    minFontSize: 12,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: DRUMM_FONT_FAMILY,
                                      color: DrummTheme.primaryTextColor(context).withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              AutoSizeText(
                                CoreUtils.removeTitleSource(widget.article.title ?? ""),
                                minFontSize: 20,
                                softWrap: true,
                                maxLines:
                                    (widget.article.title ?? "").length < 30
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
                              Row(
                                children: [
                                  ArticleDrummButton(
                                    article: ArticleEntity(),
                                    bands: [],
                                    color: DrummTheme.primaryTextColor(context),
                                  ),
                                  SizedBox(width: 12,),
                                  Flexible(
                                    child: AutoSizeText(
                                      widget.article.question ?? "",
                                      minFontSize: 14,
                                      maxLines: 2,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: DrummTheme.primaryTextColor(context),
                                        fontFamily: DRUMM_FONT_FAMILY,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              ArticleSourcesWidget(article: widget.article),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Text("Summary",style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                widget.article.summary ?? "",
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
                              if(widget.article.embedding!=null)
                              SimilarArticlesWidget(
                                params: GetSimilarArticlesParams(
                                    article: widget.article,
                                    embedding: widget.article.embedding),
                                bands: widget.bands,
                              ),
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
                        child: StartDrummButton(
                          article: widget.article,
                          onPressed: () {
                            List<Object> parameters = [];
                            parameters.add(widget.article);
                            parameters.add(widget.drummerEntity??DrummerEntity());
                            parameters.add(widget.bands);
                            Vibrate.feedback(FeedbackType.impact);
                            context.push(SCREEN_BOTTOM_CONVERSATION,
                                extra: parameters);
                          },
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CloseDialogButton(),
                        ArticleShareButton(article: widget.article),
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

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    try {
      _timer = Timer(const Duration(seconds: 5), () {
        _onPageOpenForFiveSeconds();
      });
    }catch(e){
    }
  }

  void _onPageOpenForFiveSeconds() {
    try {
      if (mounted) {
        _isTriggered = true;
        _performAction();
      }
    }catch(e){
    }
  }

  void _performAction() {
    if (kDebugMode) {
      print("Function executed after 5 seconds");
    }
    context.read<UserActivityBloc>().add(RecordUserActivity(UserActivityEntity(
          type: INTERACTION_READ,
          weight: WEIGHT_READ,
          articleId: widget.article.articleId!,
          embedding: widget.article.embedding!,
        )));
  }

  @override
  void dispose() {
    if (!_isTriggered) {
      if (kDebugMode) {
        print("Page closed before 5 seconds, function not called.");
      }
    }
    _timer?.cancel();
    super.dispose();
  }
}
