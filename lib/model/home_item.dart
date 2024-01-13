import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/model/algolia_article.dart';
import 'package:drumm_app/model/band.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../ShareWidget.dart';
import '../SoundPlayWidget.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/helper/connect_channel.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/image_uploader.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'package:http/http.dart' as http;
import 'article.dart';
import 'article_band.dart';
import 'jam.dart';

double curve = 4;

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
          const BottomFade(),
        ],
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
    int imageUrlLength = article.imageUrl?.length ?? 0;
    return Padding(
      //color: COLOR_PRIMARY_DARK.withOpacity(0.0),
      padding: const EdgeInsets.only(bottom: 32, top: 0),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(curve),
              topRight: Radius.circular(curve)),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                            color:
                                Colors.black.withOpacity(0.15), // Shadow color
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
                          height: (imageUrlLength > 0) ? 200 : 0,
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
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (article.question != null)
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(
                        left: 4, right: 4, top: 4, bottom: 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        //color: Colors.grey.shade900.withOpacity(0.65),
                        gradient: LinearGradient(colors: [
                      Colors.indigo,
                      Colors.blue.shade700,
                      Colors.lightBlue,
                    ])),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            joinDrumm(articleBand);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset('images/audio-waves.png',
                                height: 20,
                                color: Colors.white,
                                fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print("Join Drumm");
                              joinDrumm(articleBand);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "\"${article.question}\"" ?? "",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.white, //.withOpacity(0.85),
                                      fontSize: 14,
                                      //fontWeight: FontWeight.bold,
                                      //fontStyle: FontStyle.italic,
                                      fontFamily: APP_FONT_LIGHT,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Vibrate.feedback(FeedbackType.selection);
                            generateLink();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: ShareWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  height: 16,
                  color: COLOR_PRIMARY_DARK,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 8, top: 0, right: 8, bottom: 4),
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
                    child: (imageUrlLength > 0)
                        ? Text(
                            article.title ?? "",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: APP_FONT_BOLD,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            article.title ?? "",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontFamily: APP_FONT_BOLD,
                              fontWeight: FontWeight.bold,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                      left: 8, top: 0, bottom: 4, right: 12),
                  color: COLOR_PRIMARY_DARK,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(source,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontFamily: APP_FONT_MEDIUM,
                          )),
                      const Text(" • "),
                      InstagramDateTimeWidget(publishedAt: publishedAt),
                      const Text(" • "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BandDetailsPage(
                                  band: articleBand.band,
                                ),
                              ));
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          //margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900
                                .withOpacity(0.85), //.withOpacity(0.8),
                            //border: Border.all(color: Colors.grey.shade900.withOpacity(0.85),width: 2.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                articleBand.band?.name ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 16,
                  color: COLOR_PRIMARY_DARK,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      //color: COLOR_PRIMARY_DARK, //.withOpacity(0.8),
                      //border: Border.all(color: Colors.grey.shade900.withOpacity(0.85),width: 2.5),
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade900.withOpacity(0.85),
                              width: 2)),
                      //borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Description ",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SoundPlayWidget(
                                  article: article,
                                  play: false,
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              //margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: COLOR_PRIMARY_DARK, //.withOpacity(0.8),
                                border: Border.all(
                                    color:
                                    Colors.grey.shade900.withOpacity(0.85),
                                    width: 2.5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Read",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(
                                    Icons.outbound_rounded,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),
                        ExpandableText(
                          (article.description != null)
                              ? "${article.description}"
                              : (article.content != null)
                                  ? "${article.content}"
                                  : "",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontFamily: APP_FONT_LIGHT,
                          ),
                          maxLines: 3,
                          linkColor: Colors.blue,
                          expandText: 'show more',
                          collapseText: 'show less',
                          //linkColor: Colors.white,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 75),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void generateLink() async {
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = article?.title;
    jam.bandId = article?.category;
    jam.jamId = article?.jamId;
    jam.articleId = article?.articleId;
    jam.startedBy = article?.source;
    jam.imageUrl = article?.imageUrl;
    if (article?.question != null) {
      jam.question = article?.question;
    } else {
      jam.question = article?.title;
    }
    jam.count = 1;
    jam.membersID = [];
    //jam.lastActive = Timestamp.now();

    metadata = BranchContentMetaData()..addCustomMetadata('jam', jam.toJson());

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: "Drop-in Audio discussion on Drumm",
        imageUrl: article?.imageUrl ?? DEFAULT_APP_IMAGE_URL,
        contentDescription: '${article?.title}',
        contentMetadata: metadata,
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
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
      //if (context.mounted) {
      print('GeneratedLink : ${response.result}');

      String articleLink =
          "${(article?.question != null) ? "Drumm: ${article?.question}" : article?.title}\n\nTap to join the discussion on Drumm.\n${response.result}";

      Share.share(articleLink);

      // await Clipboard.setData(ClipboardData(text: response.result)).then((value) {
      // });

      // }
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
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
            height: 150,
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
