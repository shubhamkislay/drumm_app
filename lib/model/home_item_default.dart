import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/fade_in_widget.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'article.dart';

class HomeItemDefault extends StatefulWidget {
  Article article;
  bool isContainerVisible = false;
  Function(Article) updateList;
  Function(Article) openArticle;
  HomeItemDefault({Key? key, required this.article,required this.isContainerVisible, required this.updateList, required this.openArticle}) : super(key: key);

  @override
  State<HomeItemDefault> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItemDefault> {
  double fontSize = 10;
  Color iconBGColor = Colors.transparent;
  double iconHeight = 52;
  double sizedBoxedHeight = 12;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            fadeInDuration: Duration(milliseconds: 0),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            imageUrl: widget.article.imageUrl ?? "",
            errorWidget: (context, url, error) {
              //     Image.asset(
              //   "images/logo_background_white.png",
              //   color: Colors.grey.shade900
              //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
              //   width: 35,
              //   height: 35,
              // ),

              return Container(
                color: Colors.transparent,
              );
            },
          ),
        ),
        Container(
          height: double.maxFinite,
          width: double.maxFinite,
        ).frosted(
            blur: 9,
            frostColor: Colors.black), //COLOR_PRIMARY_DARK),
        Positioned.fill(
          child: CachedNetworkImage(
            fadeInDuration: Duration(milliseconds: 0),
            fit:  (widget.isContainerVisible) ? BoxFit.cover:BoxFit.fitWidth,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            imageUrl: widget.article.imageUrl ?? "",
            progressIndicatorBuilder:
                (context, url, downloadProgress) {
              return const LinearProgressIndicator(
                backgroundColor: Colors.black,
                color: Colors.black,
                // value: (downloadProgress.progress!=0)? downloadProgress.progress: 0,
              );
            },
            errorWidget: (context, url, error) {
              //     Image.asset(
              //   "images/logo_background_white.png",
              //   color: Colors.grey.shade900
              //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
              //   width: 35,
              //   height: 35,
              // ),

              return Container(
                color: Colors.transparent,
              );
            },
          ),
        ),
        if (widget.isContainerVisible&&false)
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.5),
                      Colors.transparent
                    ])),
          ),
        GestureDetector(
          onTap: (){
            setState(() {
              widget.isContainerVisible = false;
              print("Tapped images!!!!!!!!");
            });
          },
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
                left: 0, top: 100, right: 76, bottom: 44),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                  Colors.black
                      .withOpacity(0.85), //.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Vibrate.feedback(FeedbackType.light);
                widget.openArticle(widget.article);
              },
              child: Row(
                children: [
                  Container(
                    height: 120,
                    padding: EdgeInsets.only(right: 0),
                    child: FadeInContainer(
                      child: Container(
                        height: double.infinity,
                        width: 3,
                        decoration: BoxDecoration(
                          color: Color(COLOR_PRIMARY_VAL)
                              .withOpacity(1.0),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        //  color: Colors.black.withOpacity(0.20),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4)),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FadeInContainer(
                              child: AutoSizeText(
                                RemoveDuplicate
                                    .removeTitleSource(widget.article.title ??
                                    ""),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 42,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "Tap to view",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ).frosted(
                      blur: 8,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4)),
                      frostColor: Colors.grey
                          .shade900, //Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 200,
          child: AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                  "${widget.article.source} | ${widget.article.category}",
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  speed: Duration(milliseconds: 35)),
            ],
            totalRepeatCount: 1,
            repeatForever: false,
          ),
        ),
        Positioned(
          left: 8,
          bottom: 22,
          child: InstagramDateTimeWidget(
              publishedAt: widget.article.publishedAt
                  .toString() ??
                  ""),
        ),
        Positioned(
          right: 1,
          bottom: 16,
          child: Column(
            children: [
              RoundedButton(
                padding: 10,
                height: iconHeight,
                color:
                widget.article.liked ?? false
                    ? Colors.red
                    : Colors.white,
                bgColor: iconBGColor,
                hoverColor: Colors.redAccent,
                onPressed: () {
                  setState(() {
                    if (widget.article.liked ??
                        false) {
                      FirebaseDBOperations.removeLike(
                          widget.article.articleId);
                      widget.article.liked =
                      false;
                      int currentLikes = widget.article.likes ??
                          1;
                      currentLikes -= 1;
                      widget.article.likes =
                          currentLikes;
                      widget.updateList(widget.article);
                      //  _articlesController.add(articles);
                    } else {
                      FirebaseDBOperations.updateLike(
                          widget.article.articleId);

                      widget.article.liked =
                      true;
                      int currentLikes = widget.article.likes ??
                          0;
                      currentLikes += 1;
                      widget.article.likes =
                          currentLikes;
                      widget.updateList(widget.article);
                      //_articlesController.add(articles);


                      Vibrate.feedback(FeedbackType.impact);
                    }
                  });
                },
                assetPath:
                widget.article.liked ?? false
                    ? 'images/liked.png'
                    : 'images/heart.png',
              ),
              // if ((articles!.elementAt(index).likes ?? 0) > 0)
              Column(
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  if ((widget.article.likes ??
                      0) >
                      0)
                    Text(
                      "${widget.article.likes}",
                      style: TextStyle(fontSize: fontSize),
                    ),
                ],
              ),
              SizedBox(
                height: sizedBoxedHeight,
              ),
              RoundedButton(
                padding: 10,
                height: 52, //iconHeight,
                color: Colors.white,
                bgColor: iconBGColor,
                onPressed: () {
                  AISummary.showBottomSheet(
                      context,
                      widget.article ?? Article(),
                      Colors.transparent);
                },
                assetPath: 'images/sparkles.png',
              ),
              Column(
                children: [
                  SizedBox(
                    height: 0,
                  ),
                  Text(
                    "Summary",
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.transparent),
                  ),
                ],
              ),
              SizedBox(
                height: 4, //sizedBoxedHeight,
              ),
              RoundedButton(
                padding: 10,
                height: 52, //iconHeight,
                color: Colors.blue,
                bgColor: Colors.grey.shade600
                    .withOpacity(0.30), //Colors.white24,
                onPressed: () {
                  // AISummary.showBottomSheet(
                  //     context,
                  //     artcls!.elementAt(index) ?? Article(),
                  //     Colors.transparent);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(0.0)),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context)
                                .viewInsets
                                .bottom),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(0.0)),
                          child: ArticleJamPage(
                            article:
                            widget.article,
                          ),
                        ),
                      );
                    },
                  );
                },
                assetPath: 'images/drumm_logo.png',
              ),
              Column(
                children: [
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Drumms",
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              // ArticleChannel(
              //   articleID:
              //       widget.article.articleId ?? "",
              //   height: iconHeight,
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
