import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/ArticleReels.dart';
import 'package:drumm_app/HeroAnimation.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../custom/helper/BottomUpPageRoute.dart';
import '../custom/helper/image_uploader.dart';
import '../theme/theme_constants.dart';
import 'article_band.dart';
import 'home_item.dart';

class ArticleImageCard extends StatefulWidget {
  final ArticleBand articleBand;
  List<ArticleBand>? articleBands;
  bool? loading;
  String? selectedBandID;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  ArticleImageCard(
    this.articleBand, {
    Key? key,
    this.loading,
    this.selectedBandID,
    this.articleBands,
    this.lastDocument,
  }) : super(key: key);

  @override
  State<ArticleImageCard> createState() => _ArticleImageCardState();
}

class _ArticleImageCardState extends State<ArticleImageCard> {
  @override
  Widget build(BuildContext context) {
    int boosts = 0;
    double curve = 12;
    double borderWidth = 2.5;
    double bottomPadding = 100;
    double horizontalPadding = 8;
    int imageUrlLength = widget.articleBand.article?.imageUrl?.length??0;
    DateTime currentTime = DateTime.now();
    DateTime recent = currentTime.subtract(Duration(hours: 3));
    Timestamp boostTime = Timestamp.now();
    Color fadeColor = COLOR_BACKGROUND;//COLOR_ARTICLE_BACKGROUND; //.withOpacity(0.8);
    try {
      boostTime = widget.articleBand.article!.boostamp ?? Timestamp.now();
      boosts = widget.articleBand.article?.boosts ?? 0;
    } catch (e) {}

    Color colorBorder =
        (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0)
            ? COLOR_BOOST
            : Colors.grey.shade900;//COLOR_ARTICLE_BACKGROUND;//fadeColor;
    Color colorBorder2 =
        (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0)
            ? Colors.blueGrey
            : Colors.grey.shade900;//COLOR_ARTICLE_BACKGROUND;//fadeColor;
    Widget returnWidget = (widget.loading ?? false)
        ? Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(curve + 1),
              color: fadeColor, //COLOR_BACKGROUND,
              border: Border.all(color: colorBorder, width: borderWidth),
            ),
          )
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            double maxHeight = constraints.maxHeight / 2.5;
            double maxTextSize = 20;
            double minTextSize=13;
            return GestureDetector(
              onTap: () {
                if (widget.articleBands == null)
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => OpenArticlePage(
                          article: widget.articleBand.article ?? Article(),
                        ),
                      ));
                else {
                  Vibrate.feedback(FeedbackType.selection);

                  context.pushTransparentRoute(
                    ArticleReels(
                      preloadList: widget.articleBands,
                      lastDocument: widget.lastDocument,
                      selectedBandId: widget.selectedBandID ?? "For You",
                      articlePosition: widget.articleBands?.indexOf(widget.articleBand) ?? 0,
                      userConnected: false,
                      scrollController: ScrollController(),
                      tag: widget.articleBands
                              ?.elementAt(
                                  widget.articleBands?.indexOf(widget.articleBand) ?? 0)
                              .article
                              ?.articleId ??
                          "",
                    ),
                  );
                }
              },
              child: (widget.articleBand.article?.imageUrl != null && imageUrlLength>0)
                  ? Container(
                      padding: EdgeInsets.all(borderWidth),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(curve),
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                //Colors.white12,
                                colorBorder2,
                                colorBorder,
                              ]),
                        //border: Border.all(color: colorBorder,width: borderWidth)
                      ),
                      child: Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(curve),
                          color: fadeColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(curve - 2),
                          child: Column(
                            children: [
                             if(false) Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  height: double.infinity,
                                  margin:
                                  EdgeInsets.only(top: bottomPadding),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          end: Alignment.topCenter,
                                          begin: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.transparent,
                                            fadeColor,
                                          ])),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      //margin: EdgeInsets.only(top: bottomPadding),
                                      child: Hero(
                                        tag: widget.articleBands
                                            ?.elementAt(widget.articleBands
                                            ?.indexOf(widget.articleBand) ??
                                            0)
                                            .article
                                            ?.articleId ??
                                            "",
                                        child: CachedNetworkImage(
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorWidget: (context, url, error) {
                                              // setState(() {
                                              imageUrlLength = 0;
                                              //});
                                              print("Error while loading image because ${error.toString()}");
                                              //return Container(color: Colors.black,);


                                              return Container(
                                                color: COLOR_BACKGROUND,
                                                height: 300,
                                                padding: const EdgeInsets.all(48),
                                                child: Image.asset(
                                                  "images/drumm_logo.png",
                                                  color: Colors.white12,
                                                ),
                                              );
                                            },
                                            // placeholder: (context, url) => Container(
                                            //       color: Colors.grey.shade900,
                                            //     ),
                                            imageUrl:
                                            widget.articleBand.article?.imageUrl ?? "",
                                            alignment: Alignment.topCenter,
                                            fit: BoxFit.cover),

                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        alignment: Alignment.topCenter,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                end:  Alignment.bottomCenter,
                                                begin: Alignment.topCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.transparent,
                                                  fadeColor,
                                                ])),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: horizontalPadding),
                                              padding:  EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    curve - 4),
                                                color:
                                                Colors.white.withOpacity(0.1),
                                              ),
                                              child: Hero(
                                                tag:
                                                "${widget.articleBand.band?.name} ${widget.articleBand.article?.articleId}",
                                                child: AutoSizeText(
                                                  "${widget.articleBand.band?.name}",
                                                  textAlign: TextAlign.left,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  minFontSize: 8,
                                                  maxFontSize: 8,
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontFamily: APP_FONT_MEDIUM,
                                                      //fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (boosts > 0 &&
                                        boostTime.compareTo(
                                            Timestamp.fromDate(
                                                recent)) >
                                            0)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Image.asset(
                                            'images/boost_enabled.png', //'images/like_btn.png',
                                            height: 20,
                                            color: Colors.white,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment:
                                Alignment.topLeft,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    horizontalPadding,
                                    vertical: 6),
                                //height: maxHeight,
                                child: AutoSizeText(
                                  unescape.convert(widget.articleBand
                                      .article?.meta ??
                                      widget.articleBand
                                          .article?.title ??
                                      ""),
                                  textAlign: TextAlign.left,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  maxFontSize: maxTextSize,
                                  maxLines: 2,
                                  minFontSize: minTextSize,
                                  style: TextStyle(
                                      overflow: TextOverflow
                                          .ellipsis,
                                      fontSize: maxTextSize,
                                      fontWeight:
                                      FontWeight.w600,
                                      fontFamily:
                                      APP_FONT_MEDIUM,
                                      color: Colors.white),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: horizontalPadding,
                                          bottom: 8),
                                      decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(12),
                                        //color: Colors.grey.shade900.withOpacity(0.35),
                                      ),
                                      child: Text(
                                        "${widget.articleBand.article?.source}  •  ",
                                        textAlign: TextAlign.left,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily:
                                            APP_FONT_MEDIUM,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        right: horizontalPadding,
                                        bottom: 8),
                                    child:
                                    InstagramDateTimeWidget(
                                      textSize: 10,
                                      fontColor: Colors.white54,
                                      publishedAt: widget.articleBand
                                          .article
                                          ?.publishedAt
                                          .toString() ??
                                          "",
                                    ),
                                  ),
                                ],
                              ),


                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(curve + 2),
                        color: Colors.grey.shade900,
                        //border: Border.all(color: Colors.blueGrey.withOpacity(0.15,),width: 2,)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(borderWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.articleBand.article?.source != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                curve - 4),
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                          child: Hero(
                                            tag:
                                                "${widget.articleBand.band?.name} ${widget.articleBand.article?.articleId}",
                                            child: AutoSizeText(
                                              "${widget.articleBand.band?.name}",
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              minFontSize: 8,
                                              maxFontSize: 8,
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  fontFamily: APP_FONT_MEDIUM,
                                                  //fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 4,
                            ),
                            AutoSizeText(
                              unescape.convert(widget.articleBand.article?.meta ??
                                  widget.articleBand.article?.title ??
                                  ""),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxFontSize: maxTextSize+minTextSize,
                              maxLines: 3,
                              minFontSize: minTextSize,
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: maxTextSize,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: APP_FONT_MEDIUM,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            if (widget.articleBand.article?.source != null)
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: horizontalPadding, bottom: 4),
                                        decoration: BoxDecoration(
                                            //borderRadius: BorderRadius.circular(12),
                                            //color: Colors.grey.shade900.withOpacity(0.35),
                                            ),
                                        child: AutoSizeText(
                                          "${widget.articleBand.article?.source ?? ""}  •  ",
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          minFontSize: 8,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: APP_FONT_MEDIUM,
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white70),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 4, bottom: 4),
                                        child: InstagramDateTimeWidget(
                                          textSize: 10,
                                          fontColor: Colors.white70,
                                          publishedAt: widget.articleBand
                                                  .article?.publishedAt
                                                  .toString() ??
                                              "",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            );
          });
    return Stack(
      children: [
        returnWidget,
        if (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0)
          if (false)
            IgnorePointer(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'images/boost_large.png', //'images/like_btn.png',
                    height: double.maxFinite,
                    color: Colors.grey.withOpacity(0.12),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
