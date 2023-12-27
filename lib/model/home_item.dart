import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/model/band.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/helper/connect_channel.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/image_uploader.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'article.dart';
import 'article_band.dart';

class HomeItem extends StatefulWidget {
  ArticleBand articleBand;
  int index;
  String? bandId;
  String? queryID;
  bool play;
  bool isContainerVisible = false;
  VoidCallback undo;
  Function(ArticleBand) joinDrumm;
  Function(Article) updateList;
  Function(Article) openArticle;
  Function(Article, bool) playPause;

  Future<void> Function() onRefresh;
  HomeItem(
      {Key? key,
      required this.play,
      required this.index,
      required this.articleBand,
      required this.joinDrumm,
      required this.onRefresh,
      required this.undo,
      required this.isContainerVisible,
      required this.updateList,
      required this.playPause,
      this.bandId,
      this.queryID,
      required this.openArticle})
      : super(key: key);

  @override
  State<HomeItem> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem> {
  double fontSize = 10;
  Color iconBGColor =
      Colors.grey.shade900.withOpacity(0.5); //COLOR_PRIMARY_DARK;
  double iconHeight = 70;
  double sizedBoxedHeight = 12;
  double curve = 28;
  Band? band;
  @override
  Widget build(BuildContext context) {
    //setband();
    return Container(
      //color: Colors.black.withOpacity(0.95),
      decoration: BoxDecoration(
        // color: Colors
        //     .black, //COLOR_PRIMARY_DARK, //Color(0xff012036FF)
        color: Colors.black, //.withOpacity(0.0),
        borderRadius: BorderRadius.circular(curve),
        border: Border.all(color: Colors.grey.shade900, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: Stack(
          children: [
            HomeFeedData(
              onRefresh: widget.onRefresh,
              source: widget.articleBand.article?.source ?? "",
              publishedAt:
                  widget.articleBand.article?.publishedAt.toString() ?? "",
              openArticle: widget.openArticle,
              article: widget.articleBand.article ?? Article(),
              joinDrumm: widget.joinDrumm,
              articleBand: widget.articleBand,
            ),
            GestureDetector(
              onTap: () {
                if (!widget.play) {
                  setState(() {
                    widget.play = true;
                  });

                  widget.playPause(
                      widget.articleBand.article ?? Article(), widget.play);
                } else {
                  setState(() {
                    widget.play = false;
                  });
                  widget.playPause(
                      widget.articleBand.article ?? Article(), widget.play);
                }
              },
              child: SoundPlayWidget(
                play: widget.play,
              ),
            ),
            BottomFade(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class HomeFeedData extends StatelessWidget {
  Future<void> Function() onRefresh;
  Function(Article) openArticle;
  Function(ArticleBand) joinDrumm;
  String source;
  Article article;
  String publishedAt;
  ArticleBand articleBand;

  HomeFeedData(
      {required this.onRefresh,
      required this.source,
      required this.publishedAt,
      required this.openArticle,
      required this.article,
      required this.joinDrumm,
      required this.articleBand});

  @override
  Widget build(BuildContext context) {
    double curve = 28;
    return Container(
      //color: COLOR_PRIMARY_DARK.withOpacity(0.0),
      padding: EdgeInsets.only(bottom: 1),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 24),
                child: Row(
                  children: [
                    Text("${source}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 4,
                    ),
                    Text("•"),
                    SizedBox(
                      width: 4,
                    ),
                    InstagramDateTimeWidget(publishedAt: publishedAt),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 2, right: 12),
                child: GestureDetector(
                  onTap: () {
                    Vibrate.feedback(FeedbackType.impact);
                    openArticle(article);

                    ConnectToChannel.insights.viewedObjects(
                      indexName: 'articles',
                      eventName: 'Viewed Item',
                      objectIDs: [article.articleId ?? ""],
                    );
                  },
                  child: Wrap(
                    children: [
                      AutoSizeText(
                        article.title ?? "",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          //fontFamily: "alata",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              GestureDetector(
                onTap: () {
                  Vibrate.feedback(FeedbackType.impact);
                  openArticle(article);

                  ConnectToChannel.insights.viewedObjects(
                    indexName: 'articles',
                    eventName: 'Viewed Item',
                    objectIDs: [article.articleId ?? ""],
                  );
                },
                child: Container(
                  // padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(curve),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15), // Shadow color
                          offset: const Offset(
                              0, -2), // Shadow offset (horizontal, vertical)
                          blurRadius: 8, // Blur radius
                          spreadRadius: 0, // Spread radius
                        ),
                      ]),
                  child: ClipRRect(
                    //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(curve),bottomRight: Radius.circular(curve)),
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl ?? "",
                      placeholder: (context, imageUrl) {
                        String imageUrl = article.imageUrl ?? "";
                        return Container(
                          height: 200,
                          width: double.infinity,
                          // padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(curve - 4),
                          ),
                          child: Image.asset(
                            "images/logo_background_white.png",
                            color: Colors.white.withOpacity(0.1),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          //padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(curve - 4),
                          ),
                          child: Image.asset(
                            "images/logo_background_white.png",
                            color: Colors.white.withOpacity(0.1),
                          ),
                        );
                      },
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              if (article.question != null)
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    //color: COLOR_PRIMARY_DARK,//Colors.grey.shade900.withOpacity(0.75),
                    color: Colors.grey.shade900.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                    //border: Border.all(color:  Colors.grey.shade900,width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          joinDrumm(articleBand);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          child: Image.asset('images/audio-waves.png',
                              height: 32,
                              color: Colors.white,
                              fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("Join Drumm");
                            joinDrumm(articleBand);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\"${article.question}\"" ?? "",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    //fontStyle: FontStyle.italic,
                                    //fontFamily: "alata",
                                    //fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(0.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Generated by Drumm AI",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
                child: Text(
                  (article.description != null)
                      ? "${article.description}"
                      : (article.content != null)
                          ? "${article.content}"
                          : "",
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  //linkColor: Colors.white,
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class SoundPlayWidget extends StatelessWidget {
  bool play;
  SoundPlayWidget({required this.play});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade900,
                ])),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
              ),
              child: Image.asset(
                (play) ? 'images/volume.png' : 'images/mute.png',
                height: 16,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomFade extends StatelessWidget {
  const BottomFade({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: 200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.85),
                  Colors.transparent
                ])),
          ),
        ],
      ),
    );
  }
}
