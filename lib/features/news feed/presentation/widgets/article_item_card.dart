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
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_drumm_button.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ArticleItemCard extends StatefulWidget {
  ArticleEntity article;
  final List<BandEntity> bands;
  final DrummerEntity? drummerEntity;
  ArticleItemCard(
      {super.key,
      required this.article,
      required this.bands,
      required this.drummerEntity});

  @override
  State<ArticleItemCard> createState() => ArticleItemCardState();
}

class ArticleItemCardState extends State<ArticleItemCard> {
  bool _hasBeenMarkedSeen = false;

  void markAsSeen() {
    //print("_hasBeenMarkedSeen is$_hasBeenMarkedSeen for ${widget.article.articleId}");
    //if (_hasBeenMarkedSeen) return;
    //_hasBeenMarkedSeen = true;
    String id = widget.article.clusterId??widget.article.articleId??"";
    context
        .read<RemoteArticlesBloc>()
        .add(MarkArticleAsSeen(id));


  }
  @override
  Widget build(BuildContext context) {
    double height = 250;
    double curve = 12;
    return VisibilityDetector(
      key: Key(widget.article.clusterId??widget.article.articleId ?? ""),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0.5) {
          markAsSeen();
        }else{
        }
      },
      child: GestureDetector(
        onTap: () {
          Vibrate.feedback(FeedbackType.medium);
          context
              .read<UserActivityBloc>()
              .add(RecordUserActivity(UserActivityEntity(
                type: INTERACTION_OPENED,
                weight: WEIGHT_OPENED,
                articleId: widget.article.articleId!,
                embedding: widget.article.embedding ?? VectorValue([]),
              )));
          showModalBottomSheet(
            context: context,
            builder: (_) => BlocProvider.value(
                value:
                    context.read<UserActivityBloc>(), // Provide the existing bloc
                child: ReadArticlePage(
                  article: widget.article,
                  bands: widget.bands,
                  drummerEntity: widget.drummerEntity,
                )),
            isScrollControlled: true, // For making the sheet extendable
            backgroundColor: Colors.transparent,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          margin: EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
             // borderRadius: BorderRadius.circular(curve),
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
                        (widget.article.meta ?? ""),
                        minFontSize: 16,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
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
                        widget.article.category ?? "",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: CachedNetworkImage(
                  imageUrl: widget.article.imageUrl ?? "",
                  //height: height,
                  width: double.maxFinite,
                  fit: BoxFit.fitWidth,
                  errorWidget: (context, url, error) {
                    return SizedBox.shrink();
                  },
                  placeholder: (context, url) {
                    return Container(
                        color: DrummTheme.primaryItemColor(context)
                            .withAlpha(100));
                  },
                ),
              ),
              SizedBox(
                height: 12,
              ),
             if(false) Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                alignment: Alignment.bottomCenter,
                child: AutoSizeText(
                  (widget.article.title ?? ""),
                  minFontSize: 12,
                  maxFontSize: 16,
                  softWrap: true,
                  maxLines: (widget.article.title ?? "").length < 30 ? 2 : 3,
                  style: TextStyle(
                      fontSize: 16,
                      color: DrummTheme.primaryTextColor(context),
                      //fontWeight: FontWeight.w900,
                      overflow: TextOverflow.clip),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: ExpandableText(
                    (widget.article.title ?? ""),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: DRUMM_FONT_FAMILY,
                      color: DrummTheme.primaryTextColor(context),),
                  expandText: 'See more',
                  linkColor: DrummTheme.primaryTextColor(context),
                  linkStyle: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: DRUMM_FONT_FAMILY,
                  ),
                  collapseText: 'Hide',
                ),
              ),
              if (false)
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.article.imageUrl ?? "",
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
                              colors: [Colors.black, Colors.transparent])),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      height: height,
                      alignment: Alignment.bottomCenter,
                      child: AutoSizeText(
                        (widget.article.title ?? ""),
                        minFontSize: 18,
                        softWrap: true,
                        maxLines: (widget.article.title ?? "").length < 30 ? 1 : 2,
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
                height: 12,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      (widget.article.relatedImageUrls ?? []).isNotEmpty
                          ? "${(widget.article.relatedImageUrls ?? []).length + 1} sources"
                          : widget.article.source ?? "",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        //fontWeight: FontWeight.bold,
                        fontFamily: DRUMM_FONT_FAMILY,
                        color:
                            DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: DRUMM_FONT_FAMILY,
                        fontWeight: FontWeight.bold,
                        color:
                            DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                    InstagramDateTimeWidget(
                      fontColor: DrummTheme.primaryTextColor(context).withAlpha(100),
                        publishedAt: widget.article.publishedAt.toString())
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
                        articleId: widget.article.articleId!,
                        embedding: widget.article.embedding!,
                      )));

                  List<Object> parameters = [];
                  parameters.add(widget.article);
                  parameters.add(widget.drummerEntity ?? DrummerEntity());
                  parameters.add(widget.bands);

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
                        article: widget.article,
                        bands: widget.bands,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: AutoSizeText(
                          (widget.article.question ?? "").trim(),
                          minFontSize: 14,
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
      ),
    );
  }

  build2(BuildContext context) {
    double height = 250;
    double curve = 20;
    return VisibilityDetector(
      key: Key(widget.article.clusterId??widget.article.articleId ?? ""),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0.5) {
          print("Visible enough");
          markAsSeen();
        }else{
          print("Not visible enough");
        }
      },
      child: GestureDetector(
        onTap: () {
          Vibrate.feedback(FeedbackType.medium);
          context
              .read<UserActivityBloc>()
              .add(RecordUserActivity(UserActivityEntity(
            type: INTERACTION_OPENED,
            weight: WEIGHT_OPENED,
            articleId: widget.article.articleId!,
            embedding: widget.article.embedding ?? VectorValue([]),
          )));
          showModalBottomSheet(
            context: context,
            builder: (_) => BlocProvider.value(
                value:
                context.read<UserActivityBloc>(), // Provide the existing bloc
                child: ReadArticlePage(
                  article: widget.article,
                  bands: widget.bands,
                  drummerEntity: widget.drummerEntity,
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
                        (widget.article.meta ?? ""),
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
                        widget.article.category ?? "",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(curve-4),
                  child: CachedNetworkImage(
                    imageUrl: widget.article.imageUrl ?? "",
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
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                alignment: Alignment.bottomCenter,
                child: AutoSizeText(
                  (widget.article.title ?? ""),
                  minFontSize: 22,
                  softWrap: true,
                  maxLines: (widget.article.title ?? "").length < 30 ? 2 : 3,
                  style: TextStyle(
                      fontSize: 32,
                      color: DrummTheme.primaryTextColor(context),
                      //fontWeight: FontWeight.w900,
                      overflow: TextOverflow.clip),
                ),
              ),
              if (false)
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.article.imageUrl ?? "",
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
                              colors: [Colors.black, Colors.transparent])),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      height: height,
                      alignment: Alignment.bottomCenter,
                      child: AutoSizeText(
                        (widget.article.title ?? ""),
                        minFontSize: 18,
                        softWrap: true,
                        maxLines: (widget.article.title ?? "").length < 30 ? 1 : 2,
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
                height: 12,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      (widget.article.relatedImageUrls ?? []).isNotEmpty
                          ? "${(widget.article.relatedImageUrls ?? []).length + 1} sources"
                          : widget.article.source ?? "",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        //fontWeight: FontWeight.bold,
                        fontFamily: DRUMM_FONT_FAMILY,
                        color:
                        DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: DRUMM_FONT_FAMILY,
                        fontWeight: FontWeight.bold,
                        color:
                        DrummTheme.primaryTextColor(context).withAlpha(100),
                      ),
                    ),
                    InstagramDateTimeWidget(
                        fontColor: DrummTheme.primaryTextColor(context).withAlpha(100),
                        publishedAt: widget.article.publishedAt.toString())
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
                    articleId: widget.article.articleId!,
                    embedding: widget.article.embedding!,
                  )));

                  List<Object> parameters = [];
                  parameters.add(widget.article);
                  parameters.add(widget.drummerEntity ?? DrummerEntity());
                  parameters.add(widget.bands);

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
                        article: widget.article,
                        bands: widget.bands,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: AutoSizeText(
                          (widget.article.question ?? "").trim(),
                          minFontSize: 14,
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
      ),
    );
  }
}
