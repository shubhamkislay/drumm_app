import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/model/band.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
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
import 'jam.dart';
double curve = 22;
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
  Band? band;
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              GestureDetector(
                onTap: () {
                  generateLink();
                },
                child: ShareWidget(),
              ),
              SizedBox(width: 8,),
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
            ],
          ),
          const BottomFade(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void generateLink() async{

    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = widget.articleBand.article?.title;
    jam.bandId = widget.articleBand.article?.category;
    jam.jamId = widget.articleBand.article?.jamId;
    jam.articleId = widget.articleBand.article?.articleId;
    jam.startedBy = widget.articleBand.article?.source;
    jam.imageUrl = widget.articleBand.article?.imageUrl;
    if (widget.articleBand.article?.question != null)
      jam.question = widget.articleBand.article?.question;
    else
      jam.question = widget.articleBand.article?.title;
    jam.count = 1;
    jam.membersID = [];
    //jam.lastActive = Timestamp.now();

    metadata = BranchContentMetaData()
      ..addCustomMetadata('jam', jam.toJson());

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        //canonicalUrl: 'https://flutter.dev',
        title: widget.articleBand.article?.question??widget.articleBand.article?.title??"Drumm News",
        imageUrl: widget.articleBand.article?.imageUrl??DEFAULT_APP_IMAGE_URL,
        contentDescription: 'Drop-in to join the drumm',
        contentMetadata: metadata,
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');

    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      if (context.mounted) {
        print('GeneratedLink : ${response.result}');
        await Clipboard.setData(ClipboardData(text: response.result)).then((value) {
        });



      }
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');

    }
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
    int imageUrlLength = article.imageUrl?.length??0;
    return Padding(
      //color: COLOR_PRIMARY_DARK.withOpacity(0.0),
      padding: const EdgeInsets.only(bottom: 32, top: 0),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(curve),topRight: Radius.circular(curve)),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Container(
                  color: COLOR_PRIMARY_DARK,
                  height: 16,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16, top: 0),
                  color: COLOR_PRIMARY_DARK,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text("${source}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: APP_FONT_BOLD,
                            //fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(
                        width: 4,
                      ),
                      const Text(
                        "•",
                        style: TextStyle(fontFamily: APP_FONT_BOLD),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      InstagramDateTimeWidget(publishedAt: publishedAt),
                    ],
                  ),
                ),
                Container(
                  color: COLOR_PRIMARY_DARK,
                  height: 16,
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
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl ?? "",
                      placeholder: (context, imageUrl) {
                        String imageUrl = article.imageUrl ?? "";
                        return Container(
                          height: (imageUrlLength>0)?200:0,
                          width: double.infinity,
                          // padding: const EdgeInsets.all(32),
                          decoration: const BoxDecoration(
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
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(
                      left: 14, top: 12, right: 14, bottom: 12),
                  color: COLOR_PRIMARY_DARK,
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
                    child: (imageUrlLength>0)?Text(
                      article.title ?? "",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: APP_FONT_MEDIUM,
                        //fontWeight: FontWeight.bold,
                      ),
                    ):Text(
                      article.title ?? "",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: APP_FONT_MEDIUM,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                //SizedBox(height: 4),
                if (article.question != null)
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(12),
                    //margin: const EdgeInsets.all(9),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900.withOpacity(0.85),
                      //color: COLOR_PRIMARY_DARK,
                      //borderRadius: BorderRadius.circular(curve-16),
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
                            padding: const EdgeInsets.all(8),
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
                                      fontSize: 14,
                                      //fontStyle: FontStyle.italic,
                                      fontFamily: APP_FONT_MEDIUM,
                                      //fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.all(0.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Generated by Drumm AI",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontFamily: APP_FONT_MEDIUM,
                                      ),
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
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      (article.description != null)
                          ? "${article.description}"
                          : (article.content != null)
                              ? "${article.content}"
                              : "",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                        fontFamily: APP_FONT_MEDIUM,
                      ),
                      //linkColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade900.withOpacity(0.75),
            ),
            child: Image.asset(
              (play) ? 'images/volume.png' : 'images/mute.png',
              height: 12,
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class ShareWidget extends StatelessWidget {

  ShareWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade900.withOpacity(0.75),
            ),
            child: Image.asset(
              'images/share.png',
              height: 22,
              color: Colors.white,
              fit: BoxFit.contain,
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
                  ]),
              borderRadius: BorderRadius.circular(curve),
            ),
          ),
        ],
      ),
    );
  }
}
