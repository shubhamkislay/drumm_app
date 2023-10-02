import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'article.dart';

class HomeItem extends StatefulWidget {
  Article article;
  bool isContainerVisible = false;
  VoidCallback undo;
  Function(Article) updateList;
  Function(Article) openArticle;
  Future<void> Function() onRefresh;
  HomeItem(
      {Key? key,
      required this.article,
        required this.onRefresh,
        required this.undo,
      required this.isContainerVisible,
      required this.updateList,
      required this.openArticle})
      : super(key: key);

  @override
  State<HomeItem> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem> {
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900.withOpacity(0.5);//COLOR_PRIMARY_DARK;
  double iconHeight = 64;
  double sizedBoxedHeight = 12;
  double curve = 20;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(curve),
      child: Container(
        decoration: BoxDecoration(
            color: COLOR_PRIMARY_DARK,//Color(0xff012036FF)
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: Colors.grey.shade900, width: 1)),
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(curve),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15), // Shadow color
                              offset: Offset(0, -2), // Shadow offset (horizontal, vertical)
                              blurRadius: 8, // Blur radius
                              spreadRadius: 0, // Spread radius
                            ),
                          ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(curve-4),
                        child: CachedNetworkImage(
                          imageUrl: widget.article.imageUrl ?? "",
                          filterQuality: FilterQuality.low,
                          placeholder: (context, imageUrl) {
                            String imageUrl = widget.article.imageUrl ??"";
                            return Container(
                              height: (imageUrl.length < 1) ? 0:150 ,
                              color: Colors.transparent,
                              width: double.infinity,
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container();
                          },
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Vibrate.feedback(FeedbackType.impact);
                        widget.openArticle(widget.article);
                        print("Tapped article");
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${widget.article.source} | ${widget.article.category}",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                            SizedBox(
                              height: 6,
                            ),
                            Wrap(
                              children: [
                                Container(
                                  child: AutoSizeText(
                                    RemoveDuplicate.removeTitleSource(
                                        widget.article.title ?? ""),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            InstagramDateTimeWidget(
                                publishedAt:
                                    widget.article.publishedAt.toString() ?? ""),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              (widget.article.description != null)
                                  ? "${widget.article.description}"
                                  : (widget.article.content != null)
                                      ? "${widget.article.content}"
                                      : "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Tap to view",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        RoundedButton(
                          padding: 14,
                          height: iconHeight, //iconHeight,
                          color: Colors.white,
                          bgColor: iconBGColor,
                          onPressed: () {
                            AISummary.showBottomSheet(context,
                                widget.article ?? Article(), Colors.transparent);
                          },
                          assetPath: 'images/sparkles.png',
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Summary",
                          style: TextStyle(fontSize: fontSize, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              RoundedButton(
                                padding: 16,
                                height: iconHeight,
                                color: widget.article.liked ?? false
                                    ? Colors.red
                                    : Colors.white,
                                bgColor: iconBGColor,
                                hoverColor: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    if (widget.article.liked ?? false) {
                                      FirebaseDBOperations.removeLike(
                                          widget.article.articleId);
                                      widget.article.liked = false;
                                      int currentLikes = widget.article.likes ?? 1;
                                      currentLikes -= 1;
                                      widget.article.likes = currentLikes;
                                      widget.updateList(widget.article);
                                      //  _articlesController.add(articles);
                                    } else {
                                      FirebaseDBOperations.updateLike(
                                          widget.article.articleId);

                                      widget.article.liked = true;
                                      int currentLikes = widget.article.likes ?? 0;
                                      currentLikes += 1;
                                      widget.article.likes = currentLikes;
                                      widget.updateList(widget.article);
                                      //_articlesController.add(articles);

                                      Vibrate.feedback(FeedbackType.impact);
                                    }
                                  });
                                },
                                assetPath: widget.article.liked ?? false
                                    ? 'images/liked.png'
                                    : 'images/heart.png',
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                ((widget.article.likes ?? 0) > 0)
                                    ? "${widget.article.likes}"
                                    : "Likes",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ],
                          ),
                          // if ((articles!.elementAt(index).likes ?? 0) > 0)
                          Column(
                            children: [
                              RoundedButton(
                                padding: 12,
                                height: 64, //iconHeight,
                                color: Colors.white,
                                bgColor: iconBGColor, //Colors.white24,
                                onPressed: () {
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
                                            article: widget.article,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                assetPath: 'images/drumm_logo.png',
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Drumms",
                                style: TextStyle(fontSize: fontSize,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
                GestureDetector(
                  onTap: widget.undo,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_ios_new_rounded,size: 24,)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
