import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/model/band.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
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
  bool isContainerVisible = false;
  VoidCallback undo;
  Function(ArticleBand) joinDrumm;
  Function(Article) updateList;
  Function(Article) openArticle;
  Future<void> Function() onRefresh;
  HomeItem(
      {Key? key,
      required this.index,
      required this.articleBand,
      required this.joinDrumm,
      required this.onRefresh,
      required this.undo,
      required this.isContainerVisible,
      required this.updateList,
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
  double curve = 24;
  Band? band;
  @override
  Widget build(BuildContext context) {
    //setband();
    return Container(
      //height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: Container(
          height: double.infinity,
          //padding: EdgeInsets.only(bottom: 0),
          margin: EdgeInsets.only(bottom: 90),
          decoration: BoxDecoration(
            color: Colors.black, //COLOR_PRIMARY_DARK, //Color(0xff012036FF)
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: Colors.grey.shade900, width: 1.5),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(curve),
                child: Container(
                  margin: EdgeInsets.only(bottom: 1),
                  child: RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Vibrate.feedback(FeedbackType.impact);
                                  widget.openArticle(
                                      widget.articleBand.article ?? Article());

                                  ConnectToChannel.insights.viewedObjects(
                                    indexName: 'articles',
                                    eventName: 'Viewed Item',
                                    objectIDs: [
                                      widget.articleBand.article?.articleId ??
                                          ""
                                    ],
                                  );

                                  print("Viewed Item article");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "${widget.articleBand.article?.source}",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.95),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                          ),
                                          Text("•"),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          InstagramDateTimeWidget(
                                              publishedAt: widget.articleBand
                                                      .article?.publishedAt
                                                      .toString() ??
                                                  ""),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Wrap(
                                        children: [
                                          Container(
                                            child: AutoSizeText(
                                              widget.articleBand.article
                                                      ?.title ??
                                                  "",
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                //fontFamily: "newsreaderbold",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 2),
                                child: ExpandableText(
                                  (widget.articleBand.article
                                      ?.description !=
                                      null)
                                      ? "${widget.articleBand.article?.description}"
                                      : (widget.articleBand.article
                                      ?.content !=
                                      null)
                                      ? "${widget.articleBand.article?.content}"
                                      : "",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70),
                                  expandText: 'See more',
                                  collapseText: 'Hide',
                                  maxLines: 1,
                                  linkColor: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Vibrate.feedback(FeedbackType.impact);
                                  widget.openArticle(
                                      widget.articleBand.article ?? Article());

                                  ConnectToChannel.insights.viewedObjects(
                                    indexName: 'articles',
                                    eventName: 'Viewed Item',
                                    objectIDs: [
                                      widget.articleBand.article?.articleId ??
                                          ""
                                    ],
                                  );
                                },
                                child: Container(
                                  // padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(curve),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.15), // Shadow color
                                          offset: const Offset(0,
                                              -2), // Shadow offset (horizontal, vertical)
                                          blurRadius: 8, // Blur radius
                                          spreadRadius: 0, // Spread radius
                                        ),
                                      ]),
                                  child: ClipRRect(
                                    //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(curve),bottomRight: Radius.circular(curve)),
                                    child: CachedNetworkImage(
                                      imageUrl: widget
                                              .articleBand.article?.imageUrl ??
                                          "",
                                      placeholder: (context, imageUrl) {
                                        String imageUrl = widget.articleBand
                                                .article?.imageUrl ??
                                            "";
                                        return Container(
                                          height: 150,
                                          width: double.infinity,
                                          // padding: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            // borderRadius: BorderRadius.circular(curve - 4),
                                          ),
                                          child: Image.asset(
                                            "images/logo_background_white.png",
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          height: 150,
                                          width: double.infinity,
                                          //padding: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                                curve - 4),
                                          ),
                                          child: Image.asset(
                                            "images/logo_background_white.png",
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                        );
                                      },
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              if (widget.articleBand.article?.question != null)
                                Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.all(12),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    //color: COLOR_PRIMARY_DARK,//Colors.grey.shade900.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(0),
                                    color:Colors.grey.shade900,
                                    // border: Border.all(color:  Colors.grey.shade900.withOpacity(0.0),width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              widget.joinDrumm(
                                                  widget.articleBand);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(4),
                                              child: Lottie.asset(
                                                  'images/wave_drumm.json',
                                                  height: iconHeight + 16,
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
                                                widget.joinDrumm(
                                                    widget.articleBand);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "\"${widget.articleBand.article?.question}\"" ??
                                                          "",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        "Generated by Drumm AI",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white54,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    print("Setting article in view");
    super.initState();
  }

  void setband() async {
    // band = null;
    if (widget.bandId != null) {
      Band fetchedBand =
          await FirebaseDBOperations.getBand(widget.bandId ?? "");
      setState(() {
        band = fetchedBand;
        FirebaseDBOperations.articleBand.putIfAbsent(
            widget.articleBand.article?.articleId ?? "",
            () => band?.bandId ?? "");
      });
    } else {
      List<Band> userBands = await FirebaseDBOperations.getBandByUser();
      for (Band fetchedBand in userBands) {
        List bandHooks = fetchedBand.hooks ?? [];

        if (bandHooks.contains(widget.articleBand.article?.category)) {
          print(
              "BandHooks ${bandHooks} for bandName ${fetchedBand.name} and category ${widget.articleBand.article?.category}\n article ${widget.articleBand.article?.title}");
          setState(() {
            band = fetchedBand;
            FirebaseDBOperations.articleBand.putIfAbsent(
                widget.articleBand.article?.articleId ?? "",
                () => band?.bandId ?? "");
          });
          break;
        }
      }
    }
  }
}
