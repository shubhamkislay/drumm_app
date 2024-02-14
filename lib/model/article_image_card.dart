import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';

import '../theme/theme_constants.dart';
import 'home_item.dart';

class ArticleImageCard extends StatelessWidget {
  final Article article;
  List<Article>? articles;

  ArticleImageCard(
    this.article, {
    Key? key,
    this.articles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (articles == null)
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OpenArticlePage(
                  article: article,
                ),
              ));
        else {
          articles?.remove(article);
          List<Article> newList = [];
          newList.add(article);
          articles = newList + articles!;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeFeedPage(
                  preloadList: articles,
                  userConnected: false,
                  scrollController: ScrollController(),
                  tag: 'Drumm',
                ),
              ));
        }
      },
      child: (article.imageUrl != null)
          ? Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey.shade900//RandomColorBackground.generateRandomVibrantColor(),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [Colors.black, Colors.grey.shade900],
            // ),
          ),
            child: Container(
              padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: COLOR_BACKGROUND//RandomColorBackground.generateRandomVibrantColor(),
                  // gradient: LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  //   colors: [Colors.black, Colors.grey.shade900],
                  // ),
                ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: (context, url, error) {
                            return Container(
                                color: RandomColorBackground
                                    .generateRandomVibrantColor());
                          },
                          placeholder: (context, url) => Container(
                                color: Colors.grey.shade900,
                              ),
                          imageUrl: article.imageUrl ?? "",
                          fit: BoxFit.cover),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                end: Alignment.bottomCenter,
                                begin: Alignment.topCenter,
                                colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                              //Colors.transparent,
                              //Colors.black87,
                              Colors.black.withOpacity(0.95),
                                  //RandomColorBackground.generateRandomVibrantColor()
                            ])),
                        //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        child: AutoSizeText(
                                          "${article.source}",
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          minFontSize: 8,
                                          style: const TextStyle(
                                              fontSize: 8,
                                              fontFamily: APP_FONT_MEDIUM,
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: AutoSizeText(
                                       unescape.convert( article.meta??article.title ?? ""),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxFontSize: 14,
                                        maxLines: 3,
                                        minFontSize: 12,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                            //fontWeight: FontWeight.bold,
                                            fontFamily: APP_FONT_MEDIUM,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 4,bottom: 4),
                                        decoration: BoxDecoration(
                                          //borderRadius: BorderRadius.circular(12),
                                          //color: Colors.grey.shade900.withOpacity(0.35),
                                        ),
                                        child: AutoSizeText(
                                          "${article.category}",
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
                                      padding: const EdgeInsets.only(right: 4,bottom: 4),
                                      child: InstagramDateTimeWidget(
                                        textSize: 10,
                                        fontColor: Colors.white70,
                                        publishedAt: article.publishedAt.toString(),
                                      ),
                                    ),


                                  ],
                                ),
                              ],
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
                borderRadius: BorderRadius.circular(12),
                color: RandomColorBackground.generateRandomVibrantColor(),
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [Colors.black, Colors.grey.shade900],
                // ),
              ),
              child: AutoSizeText(
                article.title ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                style: const TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
    );
  }
}
