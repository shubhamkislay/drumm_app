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
import 'package:html_unescape/html_unescape.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../ShareWidget.dart';
import '../SoundPlayWidget.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/constants/Constants.dart';
import '../custom/helper/connect_channel.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/image_uploader.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'package:http/http.dart' as http;
import 'ZoomPicture.dart';
import 'article.dart';
import 'article_band.dart';
import 'jam.dart';

var unescape = HtmlUnescape();

class HomeItem extends StatefulWidget {
  ArticleBand articleBand;
  int index;
  String? bandId;
  String? queryID;
  bool play;
  bool onTop;
  bool isContainerVisible = false;
  VoidCallback undo;
  Function(ArticleBand) joinDrumm;
  Function(Article) updateList;
  Function(Article) openArticle;
  List<Color>? backgroundColor;
  YoutubePlayerController youtubePlayerController;

  Future<void> Function() onRefresh;
  HomeItem(
      {Key? key,
      required this.youtubePlayerController,
      required this.play,
      required this.index,
      required this.articleBand,
      required this.joinDrumm,
      required this.onRefresh,
      required this.undo,
      required this.isContainerVisible,
      required this.updateList,
      required this.onTop,
      this.bandId,
      this.queryID,
        this.backgroundColor,
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
      decoration: BoxDecoration(
        // color: Colors
        //     .black, //COLOR_PRIMARY_DARK, //Color(0xff012036FF)
        color: COLOR_BACKGROUND, //.withOpacity(0.0),
        borderRadius: BorderRadius.circular(CURVE),
        border: Border.all(color: Colors.grey.shade900, width: 2.5),
      ),
      child: Stack(
        children: [
          HomeFeedData(
            youtubePlayerController: widget.youtubePlayerController,
            onRefresh: widget.onRefresh,
            source: widget.articleBand.article?.source ?? "",
            publishedAt:
                widget.articleBand.article?.publishedAt.toString() ?? "",
            openArticle: widget.openArticle,
            article: widget.articleBand.article ?? Article(),
            joinDrumm: widget.joinDrumm,
            articleBand: widget.articleBand,
            backgroundColor: widget.backgroundColor,
            imageUrl: widget.articleBand.article?.imageUrl??"",
            onTop: widget.onTop,
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

class HomeFeedData extends StatefulWidget {
  Future<void> Function() onRefresh;
  Function(Article) openArticle;
  Function(ArticleBand) joinDrumm;
  String source;
  Article article;
  String publishedAt;
  ArticleBand articleBand;
  YoutubePlayerController youtubePlayerController;
  bool onTop;
  String? imageUrl;
  List<Color>? backgroundColor;

  HomeFeedData(
      {required this.onRefresh,
      required this.source,
      required this.publishedAt,
      required this.openArticle,
      required this.article,
      required this.youtubePlayerController,
      required this.joinDrumm,
      required this.articleBand,
        this.imageUrl,
        this.backgroundColor,
      required this.onTop});

  @override
  State<HomeFeedData> createState() => _HomeFeedDataState();
}

class _HomeFeedDataState extends State<HomeFeedData> {
  BranchContentMetaData metadata = BranchContentMetaData();

  BranchLinkProperties lp = BranchLinkProperties();

  late BranchUniversalObject buo;

  late BranchEvent eventStandard;

  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;

  StreamController<String> controllerData = StreamController<String>();

  StreamController<String> controllerInitSession = StreamController<String>();

  double imageHeight = 275;
  // List<Color> backgroundColor = [
  //   Colors.indigo,
  //   Colors.blue.shade700,
  //   Colors.lightBlue,
  // ];

  List<Color> backgroundColor = [Colors.black,COLOR_PRIMARY_DARK];

  double questionHeight=90;
  @override
  Widget build(BuildContext context) {
    bool muteAudio = false;
    int imageUrlLength = widget.article.imageUrl?.length ?? 0;
    double horizontalPadding = 0;

    // if(source.toLowerCase() =='youtube') {
    //   FirebaseDBOperations.youtubeController =
    //       YoutubePlayerController(
    //         initialVideoId: YoutubePlayer.convertUrlToId(article.url??"")??"",
    //         flags: const YoutubePlayerFlags(
    //           autoPlay: false,
    //           mute: false,
    //           controlsVisibleAtStart: false,
    //         ),
    //       );
    // }


    //getPalette();
    //getPalette(widget.imageUrl??"");

    return Padding(
      //color: COLOR_PRIMARY_DARK.withOpacity(0.0),
      padding: const EdgeInsets.only(bottom: 32, top: 0),
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(CURVE),
              topRight: Radius.circular(CURVE)),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                height: imageHeight+questionHeight,
                decoration: BoxDecoration(
                  //color: Colors.blue.shade700,//.withOpacity(0.65),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(CURVE - 4),
                    topRight: Radius.circular(CURVE - 4),
                  ),
                  gradient: LinearGradient(colors: widget.backgroundColor??backgroundColor),
                ),
                child: Column(
                  children: [
                    if (widget.article.question != null)
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      //margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        //color: Colors.grey.shade900.withOpacity(0.65),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(CURVE - 4),
                          topRight: Radius.circular(CURVE - 4),
                        ),
                        // gradient: LinearGradient(colors: [
                        //   Colors.indigo,
                        //   Colors.blue.shade700,
                        //   Colors.lightBlue,
                        // ])
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width:6,),
                          GestureDetector(
                            onTap: () {
                              widget.joinDrumm(widget.articleBand);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                  'images/audio-waves.png',
                                  height: 20,
                                  color: Colors.white,
                                  fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(width: 6,),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print("Join Drumm");
                                widget.joinDrumm(widget.articleBand);
                              },
                              child: Container(
                                height: questionHeight,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 4),
                                child: AutoSizeText(
                                  "\"${unescape.convert(widget.article.question ?? "")}\"" ??
                                      "",
                                  textAlign: TextAlign.left,
                                  maxFontSize: 24,
                                  minFontSize: 5,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: APP_FONT_BOLD,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          if (widget.article.question != null)
                             Container(
                              height: questionHeight
                          ),
                          Container(
                            padding:  EdgeInsets.symmetric(horizontal: horizontalPadding),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(CURVE),
                                  topRight: Radius.circular(CURVE),
                                ),
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
                            child: (widget.source.toLowerCase() != 'youtube')
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              ZoomPicture(
                                                  url: widget
                                                          .article.imageUrl ??
                                                      "https://placekitten.com/640/360"),
                                          transitionDuration:
                                              Duration(seconds: 0),
                                          reverseTransitionDuration:
                                              Duration(seconds: 0),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: widget.article.imageUrl ?? "",
                                      width: double.maxFinite,
                                      height: (imageUrlLength > 0)
                                          ? imageHeight
                                          : 0,
                                      placeholder: (context, imageUrl) {
                                        String imageUrl =
                                            widget.article.imageUrl ?? "";
                                        return Container(
                                          height: (imageUrlLength > 0)
                                              ? imageHeight
                                              : 0,
                                          width: double.infinity,
                                          // padding: const EdgeInsets.all(32),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
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
                                          height: 0,
                                          width: double.infinity,
                                          //padding: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(CURVE),
                                              topRight: Radius.circular(CURVE),
                                            ),
                                          ),
                                          child: Image.asset(
                                            "images/logo_background_white.png",
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (widget.onTop)
                                    ? YoutubePlayer(
                                        controller:
                                            widget.youtubePlayerController,
                                        bottomActions: [
                                          ProgressBar(
                                            isExpanded: true,
                                            colors: const ProgressBarColors(
                                                playedColor: Colors.white70,
                                                bufferedColor: Colors.white24,
                                                handleColor: Colors.transparent,
                                                backgroundColor:
                                                    Colors.white12),
                                          ),
                                        ],
                                        actionsPadding: const EdgeInsets.all(0),
                                        topActions: [
                                          Expanded(child: Container()),
                                          VolumeButton(
                                              youtubePlayerController: widget
                                                  .youtubePlayerController)
                                        ],
                                        thumbnail: Image.network(
                                          YoutubePlayer.getThumbnail(
                                              videoId: convertUrlToId(
                                                      widget.article.url ??
                                                          "") ??
                                                  ""),
                                          fit: BoxFit.cover,
                                          loadingBuilder: (_, child,
                                                  progress) =>
                                              progress == null
                                                  ? child
                                                  : Container(
                                                      color:
                                                          Colors.transparent),
                                          errorBuilder: (context, _, __) =>
                                              Image.network(
                                            YoutubePlayer.getThumbnail(
                                                videoId: convertUrlToId(
                                                        widget.article.url ??
                                                            "") ??
                                                    ""),
                                            fit: BoxFit.cover,
                                            loadingBuilder: (_, child,
                                                    progress) =>
                                                progress == null
                                                    ? child
                                                    : Container(
                                                        color: Colors.black),
                                            errorBuilder: (context, _, __) =>
                                                Container(),
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        YoutubePlayer.getThumbnail(
                                            videoId: convertUrlToId(
                                                    widget.article.url ?? "") ??
                                                ""),
                                        fit: BoxFit.cover,
                                        loadingBuilder: (_, child, progress) =>
                                            progress == null
                                                ? child
                                                : Container(
                                                    color: Colors.transparent),
                                        errorBuilder: (context, _, __) =>
                                            Image.network(
                                          YoutubePlayer.getThumbnail(
                                              videoId: convertUrlToId(
                                                      widget.article.url ??
                                                          "") ??
                                                  ""),
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (_, child, progress) =>
                                                  progress == null
                                                      ? child
                                                      : Container(
                                                          color: Colors.black),
                                          errorBuilder: (context, _, __) =>
                                              Container(),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 16,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      color: COLOR_PRIMARY_DARK,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      padding: const EdgeInsets.only(
                          left: 10, top: 0, bottom: 4, right: 10),
                      color: COLOR_PRIMARY_DARK,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(widget.source,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                      fontFamily: APP_FONT_MEDIUM,
                                    )),
                                const Text(" • "),
                                InstagramDateTimeWidget(
                                    publishedAt: widget.publishedAt),
                                const Text(" • "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BandDetailsPage(
                                            band: widget.articleBand.band,
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
                                          widget.articleBand.band?.name ?? "",
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
                          GestureDetector(
                            onTap: () {
                              Vibrate.feedback(FeedbackType.selection);
                              generateLink();
                            },
                            child:  ShareWidget(
                              iconHeight: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      padding: const EdgeInsets.only(
                          left: 10, top: 0, right: 10, bottom: 12),
                      color: COLOR_PRIMARY_DARK,
                      child: GestureDetector(
                        onTap: () {
                          Vibrate.feedback(FeedbackType.impact);
                          widget.openArticle(widget.article);

                          ConnectToChannel.insights.viewedObjects(
                            indexName: 'articles',
                            eventName: 'Viewed Item',
                            objectIDs: [widget.article.articleId ?? ""],
                          );
                        },
                        child: (imageUrlLength > 0)
                            ? Text(
                                unescape.convert(widget.article.title ?? ""),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.75,
                                  fontFamily: APP_FONT_BOLD,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                unescape.convert(widget.article.title ?? ""),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      (widget.source.toLowerCase() != 'youtube')
                                          ? 32
                                          : 16.75,
                                  fontFamily: APP_FONT_BOLD,
                                  fontWeight: FontWeight.bold,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {

                        Vibrate.feedback(FeedbackType.impact);
                        widget.openArticle(widget.article);
                        ConnectToChannel.insights.viewedObjects(
                          indexName: 'articles',
                          eventName: 'Viewed Item',
                          objectIDs: [widget.article.articleId ?? ""],
                        );

                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        decoration:  BoxDecoration(
                          color: COLOR_PRIMARY_DARK, //.withOpacity(0.8),
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade900.withOpacity(0.85),width: 2)
                          ),
                          // border: Border(
                          //     top: BorderSide(
                          //         color: Colors.grey.shade900.withOpacity(0.85),
                          //         width: 2)),
                          //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(CURVE),bottomRight: Radius.circular(CURVE)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      article: widget.article,
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
                                    color: Colors.grey.shade900
                                        .withOpacity(0.85), //.withOpacity(0.8),
                                    border: Border.all(
                                        color: Colors.grey.shade900
                                            .withOpacity(0.85),
                                        width: 2.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Text(
                                        "Read",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                      ),
                                      //Image.asset("images/read-more.png",color: Colors.white,height: 18,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              (widget.source.toLowerCase() == 'youtube')
                                  ? unescape.convert(widget.article.title ?? "")
                                  : (widget.article.description != null)
                                      ? unescape.convert(
                                          widget.article.description ?? "")
                                      : (widget.article.content != null)
                                          ? unescape.convert(
                                              widget.article.content ?? "")
                                          : "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                                fontFamily: APP_FONT_LIGHT,
                              ),
                              //maxLines: 2,
                              // linkColor: Colors.blue,
                              // expandText: 'show more',
                              // collapseText: 'show less',
                              //linkColor: Colors.white,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: questionHeight+50),
                  ],
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

    super.initState();


  }

  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:music\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  void generateLink() async {
    String imageUrl = widget.article?.imageUrl ?? DEFAULT_APP_IMAGE_URL;
    String source = widget.article?.source ?? "";
    if (source.toLowerCase() == "youtube") {
      imageUrl = YoutubePlayer.getThumbnail(
          videoId:
              YoutubePlayer.convertUrlToId(widget.article.url ?? "") ?? "");
    }
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = unescape.convert(widget.article?.title ?? "");
    jam.bandId = widget.article?.category;
    jam.jamId = widget.article?.jamId;
    jam.articleId = widget.article?.articleId;
    jam.startedBy = widget.article?.source;
    jam.imageUrl = imageUrl;
    if (widget.article?.question != null) {
      jam.question = unescape.convert(widget.article?.question ?? "");
    } else {
      jam.question = unescape.convert(widget.article?.title ?? "");
    }
    jam.count = 1;
    jam.membersID = [];
    //jam.lastActive = Timestamp.now();

    metadata = BranchContentMetaData()..addCustomMetadata('jam', jam.toJson());

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: "Drop-in Audio discussion on Drumm",
        imageUrl: imageUrl,
        contentDescription: '${unescape.convert(widget.article?.title ?? "")}',
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
          "${(widget.article?.question != null) ? "Drumm: ${unescape.convert(widget.article?.question ?? "")}" : unescape.convert(widget.article?.title ?? "")}\n\nTap to join the discussion on Drumm.\n${response.result}";

      Share.share(articleLink);

      // await Clipboard.setData(ClipboardData(text: response.result)).then((value) {
      // });

      // }
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

   void getPalette(String url) async{
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
    NetworkImage(url),
      maximumColorCount: 3,
    );
    List<Color>  extractedColors= [];
    extractedColors.add(paletteGenerator.darkVibrantColor?.color??Colors.black);
    extractedColors.add(paletteGenerator.darkMutedColor?.color??Colors.black);
    if(extractedColors.length>=2) {
      setState(() {
      backgroundColor = extractedColors;
    });
    }
  }
}

class VolumeButton extends StatefulWidget {
  YoutubePlayerController youtubePlayerController;

  VolumeButton({Key? key, required this.youtubePlayerController})
      : super(key: key);

  @override
  State<VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  bool muteAudio = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!muteAudio) {
            widget.youtubePlayerController.mute();
            setState(() {
              muteAudio = true;
            });
          } else {
            widget.youtubePlayerController.unMute();
            setState(() {
              muteAudio = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: (muteAudio)
              ? const Icon(Icons.volume_mute)
              : const Icon(Icons.volume_up),
        ));
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
                    COLOR_BACKGROUND,
                   // Colors.black, //.withOpacity(0.95),
                    COLOR_BACKGROUND.withOpacity(0.75),
                    Colors.transparent
                  ]),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(CURVE),bottomLeft: Radius.circular(CURVE)),
            ),
          ),
        ],
      ),
    );
  }
}
