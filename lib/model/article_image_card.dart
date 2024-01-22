import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';

import '../theme/theme_constants.dart';

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
        if(articles==null)
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OpenArticlePage(
                article: article,
              ),
            ));
        else{
          articles?.remove(article);
          List<Article> newList = [];
          newList.add(article);
          articles = newList+articles!;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeFeedPage(
                  preloadList: articles,
                  userConnected: false,
                  scrollController: ScrollController(), tag: 'Drumm',
                ),
              ));
        }

      },
      child: (article.imageUrl != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    width: double.infinity,
                      height: double.infinity,
                      errorWidget: (context,url,error) {return Container( color: RandomColorBackground.generateRandomVibrantColor());},
                      placeholder: (context, url) => Container(color: Colors.grey.shade900,),
                      imageUrl: article.imageUrl ?? "", fit: BoxFit.cover),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,
                        colors: [
                         // Colors.grey.shade900.withOpacity(0.75),
                          Colors.transparent,
                          //Colors.black87,
                          Colors.grey.shade900
                          //RandomColorBackground.generateRandomVibrantColor()
                              .withOpacity(0.85)
                        ]
                      )
                    ),
                    //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                       if(false) Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                "${article.source} | ${article.category}",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                minFontSize: 8,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: APP_FONT_MEDIUM,
                                  //fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ).frosted(blur: 3,frostColor: Colors.grey.shade900),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: AutoSizeText(article.title??"",
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxFontSize: 12,
                            maxLines: 3,
                            minFontSize: 8,

                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,

                              //fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_MEDIUM,
                                color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: RandomColorBackground.generateRandomVibrantColor(),
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [Colors.black, Colors.grey.shade900],
                // ),
              ),
              child: AutoSizeText(
                article.title??"",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
    );
  }
}
