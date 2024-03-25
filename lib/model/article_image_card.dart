import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../custom/helper/BottomUpPageRoute.dart';
import '../theme/theme_constants.dart';
import 'article_band.dart';
import 'home_item.dart';

class ArticleImageCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    int boosts = 0;
    DateTime currentTime = DateTime.now();
    DateTime recent = currentTime.subtract(Duration(hours: 3));
    Timestamp boostTime = Timestamp.now();
    try {
      boostTime = articleBand.article!.boostamp ?? Timestamp.now();
      boosts = articleBand.article?.boosts ?? 0;
    }catch(e){

    }

    Color colorBorder = (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent))>0 ) ? COLOR_BOOST : Colors.white12;
    Color colorBorder2 = (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent))>0) ? Colors.blueGrey : Colors.white12;
    Widget returnWidget = (loading ?? false)
        ? Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colors.grey.shade900, //COLOR_BACKGROUND,
              border: Border.all(color: colorBorder, width: 3),
            ),
          )
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            double maxHeight = constraints.maxHeight / 2.5;
            return GestureDetector(
              onTap: () {
                if (articleBands == null)
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => OpenArticlePage(
                          article: articleBand.article ?? Article(),
                        ),
                      ));
                else {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ArticleReels(
                  //         preloadList: articleBands,
                  //         articlePosition: articleBands?.indexOf(articleBand)??0,
                  //         userConnected: false,
                  //         scrollController: ScrollController(),
                  //         tag: articleBands?.elementAt(articleBands?.indexOf(articleBand)??0).article?.articleId??"",
                  //       ),
                  //     ));

                  Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => ArticleReels(
                        preloadList: articleBands,
                        lastDocument: lastDocument,
                        selectedBandId: selectedBandID ?? "For You",
                        articlePosition:
                            articleBands?.indexOf(articleBand) ?? 0,
                        userConnected: false,
                        scrollController: ScrollController(),
                        tag: articleBands
                                ?.elementAt(
                                    articleBands?.indexOf(articleBand) ?? 0)
                                .article
                                ?.articleId ??
                            "",
                      ),
                    ),
                  );
                }
              },
              child: (articleBand.article?.imageUrl != null)
                  ? Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                //Colors.white12,
                                colorBorder2,
                                colorBorder,
                              ])),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: COLOR_BACKGROUND,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Hero(
                                tag: articleBands
                                        ?.elementAt(
                                            articleBands?.indexOf(articleBand) ??
                                                0)
                                        .article
                                        ?.articleId ??
                                    "",
                                child: CachedNetworkImage(
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorWidget: (context, url, error) {
                                      return Container();
                                    },
                                    placeholder: (context, url) => Container(
                                          color: Colors.grey.shade900,
                                        ),
                                    imageUrl: articleBand.article?.imageUrl ?? "",
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover),
                              ),
                              if (false)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  color: Colors.black,
                                  width: double.maxFinite,
                                  child: AutoSizeText(
                                    unescape.convert(articleBand.article?.meta ??
                                        articleBand.article?.title ??
                                        ""),
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxFontSize: 15,
                                    maxLines: 3,
                                    minFontSize: 10,
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 15,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: APP_FONT_MEDIUM,
                                        color: Colors.white),
                                  ),
                                ),
                              if (false)
                                Container(
                                  color: Colors.black,
                                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(12),
                                              // color: Colors.black,
                                              ),
                                          child: AutoSizeText(
                                            "${articleBand.article?.source}",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            minFontSize: 8,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontFamily: APP_FONT_MEDIUM,
                                                //fontWeight: FontWeight.bold,
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                      const Text(" • "),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            right: 4, bottom: 4),
                                        child: InstagramDateTimeWidget(
                                          textSize: 10,
                                          fontColor: Colors.white70,
                                          publishedAt: articleBand
                                                  .article?.publishedAt
                                                  .toString() ??
                                              "",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (true)
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          end: Alignment.bottomCenter,
                                          begin: Alignment.topCenter,
                                          colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.75),
                                        //Colors.black,
                                        Colors.black,
                                      ])),
                                  //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                  color: Colors.grey.shade800
                                                      .withOpacity(0.65)),
                                              child: Hero(
                                                tag:
                                                    "${articleBand.band?.name} ${articleBand.article?.articleId}",
                                                child: AutoSizeText(
                                                  "${articleBand.band?.name}",
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  minFontSize: 8,
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontFamily:
                                                          APP_FONT_MEDIUM,
                                                      //fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent))>0)
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                child: Image.asset(
                                                  'images/boost_enabled.png', //'images/like_btn.png',
                                                  height: 18,
                                                  color: Colors.white,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  alignment: Alignment.bottomLeft,
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  height: maxHeight,
                                                  child: AutoSizeText(
                                                    unescape.convert(articleBand
                                                            .article?.meta ??
                                                        articleBand
                                                            .article?.title ??
                                                        ""),
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxFontSize: 17,
                                                    maxLines: 3,
                                                    minFontSize: 10,
                                                    style: TextStyle(
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            APP_FONT_MEDIUM,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4, bottom: 4),
                                                    decoration: BoxDecoration(
                                                        //borderRadius: BorderRadius.circular(12),
                                                        //color: Colors.grey.shade900.withOpacity(0.35),
                                                        ),
                                                    child: Text(
                                                      "${articleBand.article?.source}",
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          fontFamily:
                                                              APP_FONT_MEDIUM,
                                                          //fontWeight: FontWeight.bold,
                                                          color: Colors.white70),
                                                    ),
                                                  ),
                                                ),
                                                const Text(" • "),
                                                Container(
                                                  padding: const EdgeInsets.only(
                                                      right: 4, bottom: 4),
                                                  child: InstagramDateTimeWidget(
                                                    textSize: 10,
                                                    fontColor: Colors.white70,
                                                    publishedAt: articleBand
                                                            .article?.publishedAt
                                                            .toString() ??
                                                        "",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade900,
                        //border: Border.all(color: Colors.blueGrey.withOpacity(0.15,),width: 2,)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (articleBand.article?.source != null)
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                          child: Hero(
                                            tag:
                                                "${articleBand.band?.name} ${articleBand.article?.articleId}",
                                            child: AutoSizeText(
                                              "${articleBand.band?.name}",
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              minFontSize: 8,
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
                              unescape.convert(articleBand.article?.meta ??
                                  articleBand.article?.title ??
                                  ""),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxFontSize: 17,
                              maxLines: 3,
                              minFontSize: 10,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 17,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: APP_FONT_MEDIUM,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            if (articleBand.article?.source != null)
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 4, bottom: 4),
                                        decoration: BoxDecoration(
                                            //borderRadius: BorderRadius.circular(12),
                                            //color: Colors.grey.shade900.withOpacity(0.35),
                                            ),
                                        child: AutoSizeText(
                                          "${articleBand.article?.source ?? ""}",
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
                                    const Text(" • "),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 4, bottom: 4),
                                        child: InstagramDateTimeWidget(
                                          textSize: 10,
                                          fontColor: Colors.white70,
                                          publishedAt: articleBand
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
    return returnWidget;
  }
}
