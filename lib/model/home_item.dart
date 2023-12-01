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
  double iconHeight = 64;
  double sizedBoxedHeight = 12;
  double curve = 20;
  Band? band;
  @override
  Widget build(BuildContext context) {
    //setband();
    return ClipRRect(
      borderRadius: BorderRadius.circular(curve),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black,//COLOR_PRIMARY_DARK, //Color(0xff012036FF)
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
                    GestureDetector(
                      onTap: () {
                        Vibrate.feedback(FeedbackType.impact);
                        widget.openArticle(
                            widget.articleBand.article ?? Article());

                        ConnectToChannel.insights.viewedObjects(
                          indexName: 'articles',
                          eventName: 'Viewed Item',
                          objectIDs: [
                            widget.articleBand.article?.articleId ?? ""
                          ],
                        );

                        print("Viewed Item article");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Vibrate.feedback(FeedbackType.selection);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BandDetailsPage(
                                              band: widget.articleBand.band ??
                                                  Band(),
                                            )));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.index != 0)
                                    GestureDetector(
                                      onTap: widget.undo,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(48),
                                          ),
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: 24,
                                          )),
                                    ),
                                  if (widget.articleBand.band != null)
                                    Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 3, 3, 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                         if(false) SizedBox(
                                            height: 28,
                                            width: 28,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              child: CachedNetworkImage(
                                                imageUrl: modifyImageUrl(
                                                    widget.articleBand.band
                                                            ?.url ??
                                                        "",
                                                    "100x100"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 0,
                                          ),
                                        if(false)  Text(
                                            "${widget.articleBand.band?.name}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: "alata"),
                                          ),
                                          const SizedBox(
                                            width: 0,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 3, 8, 3),
                                            decoration: BoxDecoration(
                                              color: COLOR_PRIMARY_DARK,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              "${widget.articleBand.article?.category}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: "alata"),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text("${widget.articleBand.article?.source}",
                                      style:  TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                SizedBox(width: 4,),
                                Text("•"),
                                SizedBox(width: 4,),
                                InstagramDateTimeWidget(
                                    publishedAt: widget
                                        .articleBand.article?.publishedAt
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
                                  child: AutoSizeText(widget.articleBand.article?.title ??
                                      "",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            ExpandableText(
                              (widget.articleBand.article?.description != null)
                                  ? "${widget.articleBand.article?.description}"
                                  : (widget.articleBand.article?.content !=
                                          null)
                                      ? "${widget.articleBand.article?.content}"
                                      : "",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white38),
                              expandText: 'See more',
                              collapseText: 'Hide',
                              maxLines: 1,
                              linkColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Vibrate.feedback(FeedbackType.impact);
                        widget.openArticle(
                            widget.articleBand.article ?? Article());

                        ConnectToChannel.insights.viewedObjects(
                          indexName: 'articles',
                          eventName: 'Viewed Item',
                          objectIDs: [
                            widget.articleBand.article?.articleId ?? ""
                          ],
                        );
                      },
                      child: Container(
                       // padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(curve),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.15), // Shadow color
                                offset: const Offset(0,
                                    -2), // Shadow offset (horizontal, vertical)
                                blurRadius: 8, // Blur radius
                                spreadRadius: 0, // Spread radius
                              ),
                            ]),
                        child: ClipRRect(
                         // borderRadius: BorderRadius.circular(curve - 4),
                          child: CachedNetworkImage(
                            imageUrl: widget.articleBand.article?.imageUrl ?? "",
                            filterQuality: FilterQuality.low,
                            placeholder: (context, imageUrl) {
                              String imageUrl =
                                  widget.articleBand.article?.imageUrl ?? "";
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
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                height: 0,
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
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
                    const SizedBox(
                      height: 16,
                    ),

                   if( widget.articleBand.article?.question!=null) Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          color: COLOR_PRIMARY_DARK,//Colors.grey.shade900.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color:  Colors.grey.shade900.withOpacity(0.5),width: 2)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                             if(false) RoundedButton(
                                padding: 14,
                                height: iconHeight, //iconHeight,
                                color: Colors.white,
                                bgColor: Colors.black,//COLOR_PRIMARY_DARK,//iconBGColor,
                                onPressed: () {
                                  widget.joinDrumm(widget.articleBand);
                                },
                                assetPath: 'images/team_active.png',
                              ),
                              GestureDetector(
                                onTap: (){
                                  widget.joinDrumm(widget.articleBand);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(12),
                                  child: Lottie.asset('images/wave_drumm.json',height: iconHeight,fit:BoxFit.contain),
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    print("Join Drumm");
                                    widget.joinDrumm(widget.articleBand);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                              widget.articleBand.article?.question ?? "",
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(height: 4,),
                                        Container(
                                          width: double.infinity,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(0.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text("Generated by Drumm AI",
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                color: Colors.white38,
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


                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32,
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
                                color:
                                widget.articleBand.article?.liked ?? false
                                    ? Colors.red
                                    : Colors.white,
                                bgColor: iconBGColor,
                                hoverColor: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    if (widget.articleBand.article?.liked ??
                                        false) {
                                      FirebaseDBOperations.removeLike(widget
                                          .articleBand.article?.articleId);
                                      widget.articleBand.article?.liked = false;
                                      int currentLikes =
                                          widget.articleBand.article?.likes ??
                                              1;
                                      currentLikes -= 1;
                                      widget.articleBand.article?.likes =
                                          currentLikes;
                                      widget.updateList(
                                          widget.articleBand.article ??
                                              Article());
                                      //  _articlesController.add(articles);
                                    } else {
                                      FirebaseDBOperations.updateLike(widget
                                          .articleBand.article?.articleId);

                                      ConnectToChannel.insights
                                          .convertedObjectsAfterSearch(
                                        indexName: 'articles',
                                        eventName: 'Liked article',
                                        queryID: widget.queryID ?? 'query id',
                                        objectIDs: [
                                          widget.articleBand.article
                                              ?.articleId ??
                                              ""
                                        ],
                                      );

                                      widget.articleBand.article?.liked = true;
                                      int currentLikes =
                                          widget.articleBand.article?.likes ??
                                              0;
                                      currentLikes += 1;
                                      widget.articleBand.article?.likes =
                                          currentLikes;
                                      widget.updateList(
                                          widget.articleBand.article ??
                                              Article());
                                      //_articlesController.add(articles);

                                      Vibrate.feedback(FeedbackType.impact);
                                    }
                                  });
                                },
                                assetPath:
                                widget.articleBand.article?.liked ?? false
                                    ? 'images/liked.png'
                                    : 'images/heart.png',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                ((widget.articleBand.article?.likes ?? 0) > 0)
                                    ? "${widget.articleBand.article?.likes}"
                                    : "Like",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RoundedButton(
                                padding: 14,
                                height: iconHeight, //iconHeight,
                                color: Colors.white,
                                bgColor: iconBGColor,
                                onPressed: () {
                                  AISummary.showBottomSheet(
                                      context,
                                      widget.articleBand.article ?? Article(),
                                      Colors.transparent);
                                },
                                assetPath: 'images/sparkles.png',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Summary",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: fontSize, color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RoundedButton(
                                padding: 14,
                                height: iconHeight, //iconHeight,
                                color: Colors.white,
                                bgColor: iconBGColor,
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.grey.shade900,
                                      shape: const RoundedRectangleBorder(
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
                                  borderRadius:
                                  const BorderRadius.vertical(
                                  top: Radius.circular(0.0)),
                                  child: ArticleJamPage(
                                  article:
                                  widget.articleBand.article ??
                                  Article(),
                                  ),
                                  ),
                                  );
                                  },);
                                },
                                assetPath: 'images/drumm_logo.png',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Drumms",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: fontSize, color: Colors.white),
                              ),
                            ],
                          ),

                          // if ((articles!.elementAt(index).likes ?? 0) > 0)

                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                  ],
                ),

              ],
            ),
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
