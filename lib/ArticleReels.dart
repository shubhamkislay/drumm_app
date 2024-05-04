import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/article_jam_page.dart';
import 'package:drumm_app/auto_join_option.dart';
import 'package:drumm_app/create_post.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/custom/drumm_app_bar.dart';
import 'package:drumm_app/custom/fade_in_text.dart';
import 'package:drumm_app/custom/fade_in_widget.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/custom/listener/connection_listener.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drumm_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/news_model.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:http/http.dart' as http;
import 'package:drumm_app/view_article_jams.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'ArticleDrummButton.dart';
import 'JoinDrummButton.dart';
import 'LikeBtn.dart';
import 'ShareWidget.dart';
import 'SoundPlayWidget.dart';
import 'band_details_page.dart';
import 'custom/DrummBottomDialog.dart';

import 'custom/helper/CustomPageViewPhysics.dart';
import 'model/ZoomPicture.dart';
import 'model/article_band.dart';
import 'model/home_item.dart';

String getCurrentUserID() {
  final User? user = FirebaseAuth.instance.currentUser;
  final String userID = user?.uid ?? '';
  return userID;
}

class ArticleReels extends StatefulWidget {
  ArticleReels(
      {Key? key,
      this.title,
      this.preloadList,
      this.themeManager,
      this.analytics,
      this.observer,
      this.articlePosition,
      required this.tag,
      required this.lastDocument,
      required this.selectedBandId,
      required this.userConnected,
      required this.scrollController})
      : super(key: key);
  String? title;
  String tag;
  int? articlePosition;
  String selectedBandId;
  ThemeManager? themeManager;
  final ScrollController scrollController;
  FirebaseAnalytics? analytics;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  FirebaseAnalyticsObserver? observer;
  final bool userConnected;
  List<ArticleBand>? preloadList;
  @override
  ArticleReelsState createState() => ArticleReelsState();
}

class ArticleReelsState extends State<ArticleReels>
    with
        AutomaticKeepAliveClientMixin<ArticleReels>,
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin {
  NewsModel newModel = NewsModel();
  NewsModel headlinesModel = NewsModel();
  List<Object> questionsAsked = [];
  List<ArticleBand> articles = [];
  late PageController _pageController;
  List<NetworkImage> _preloadedImages = [];
  late List<Band> bandList;

  Set<String> imageSet = {};

  String summary = "Fetching summary from AI...";

  final Duration _debounceDuration = const Duration(milliseconds: 100);

  HashSet<String?> articleIDs = HashSet();

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  final StreamController<List<ArticleBand>> _articlesController =
      StreamController<List<ArticleBand>>();
  int _currentPage = 0;
  int _pageSize = 10;

  bool noImage = false;
  bool liked = false;

  Color setColor = Colors.white;

  double iconHeight = 52;

  Color iconBGColor = Colors.transparent;

  double sizedBoxedHeight = 12;

  double fontSize = 10;
  bool autoJoinDrumms = false;

  bool loaded = false;

  bool loadLatest = true;

  Color iconColor = Colors.white.withOpacity(1.0);

  int currentVisiblePageIndex = 0;

  bool isContainerVisible = true;

  List<Jam> drumms = [];

  List<DrummCard> drummCards = [];

  Drummer? drummer;

  bool fromSearch = false;

  List<Jam> openDrumms = [];

  List<DrummCard> openDrummCards =
      []; //Colors.white.withOpacity(0.1); // Number of documents to fetch per page

  // Choose from any of these available methods

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool refreshList = true;

  double questionHeight = 90;

  List<Color> backgroundColor = JOIN_COLOR;

  bool showCurrentDrummWidget = false; // Set your desired refresh interval here
  Jam currentJam = Jam();

  bool _isScrolling = false;

  bool openDrumm = false;

  ArticleBand? articleOnTop = ArticleBand();

  double borderCurve = 10;

  double horizontalPadding = 18;

  var _scrollParent = false;

  bool isBoosted = false;

  bool errorImage = false;

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.horizontal,
      isFullScreen: true,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: 1.0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: <Widget>[
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              )),
                          child: getNewsArticles(), //listDemoVertical()),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SafeArea(
                        top: false,
                        right: false,
                        left: false,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SoundPlayWidget(
                                article: articleOnTop?.article ?? Article(),
                                backgroundColor: COLOR_BACKGROUND,
                                imageSize: 18,
                                paddingSize: 46,
                                play: false,
                              ),
                              Container(
                                height: 46,
                                width: 46,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: COLOR_BACKGROUND,
                                    borderRadius: BorderRadius.circular(44),
                                    border: Border.all(
                                        color: Colors.grey.shade900,
                                        width: 2.5)),
                                child: ArticleDrummButton(
                                    iconSize: 44,
                                    articleOnScreen:
                                        articleOnTop?.article ?? Article()),
                              ),
                              if (!showCurrentDrummWidget)
                                JoinDrummButton(
                                  btnPadding: 12,
                                  height: 38,
                                  onTap: () {
                                    drumJoinDialog();
                                  },
                                ),
                              if (showCurrentDrummWidget)
                                GestureDetector(
                                  onTap: () {
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
                                            child: JamRoomPage(
                                              jam: currentJam,
                                              open: openDrumm,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(64),
                                      border: Border.all(
                                          color: Colors.white, width: 2.5),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(2.5),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(56),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  currentJam.imageUrl ?? "",
                                              fit: BoxFit.cover,
                                              height: 56,
                                              width: 56,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(42),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            42),
                                                    color: Colors.transparent,
                                                    //gradient: LinearGradient(colors: JOIN_COLOR),
                                                  ),
                                                  child: Image.asset(
                                                    'images/audio-waves.png',
                                                    height: iconHeight,
                                                    color: Colors.white,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(42),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(42),
                                              color: Colors.transparent,
                                              //gradient: LinearGradient(colors: JOIN_COLOR),
                                            ),
                                            child: Image.asset(
                                              'images/audio-waves.png',
                                              height: iconHeight - 12,
                                              color: Colors.white
                                                  .withOpacity(0.35),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              LikeBtn(
                                article: articleOnTop?.article ?? Article(),
                                userBoosted: isBoosted,
                                boostedCallback: (boost) {
                                  setState(() {
                                    if (boost) {
                                      int currentBoosts =
                                          articleOnTop?.article?.boosts ?? 0;
                                      articleOnTop?.article?.boosts =
                                          currentBoosts + 1;
                                      articleOnTop?.article?.boostamp =
                                          Timestamp.now();
                                    } else {
                                      int currentBoosts =
                                          articleOnTop?.article?.boosts ?? 0;
                                      articleOnTop?.article?.boosts =
                                          currentBoosts - 1;
                                    }
                                    isBoosted = boost;
                                  });
                                },
                              ),
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(44),
                                    border: Border.all(
                                        color: Colors.grey.shade900,
                                        width: 2.5)),
                                child: Center(
                                  child: ShareWidget(
                                    article: articleOnTop?.article ?? Article(),
                                    backgroundColor: COLOR_BACKGROUND,
                                    iconHeight: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  if (true)
                    SafeArea(
                      child: IgnorePointer(
                        child: Container(
                          alignment: Alignment.topCenter,
                          height: 200,
                          //padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderCurve),
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.transparent,
                                  //Colors.black,
                                  Colors.black.withOpacity(0.35),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  if (fromSearch)
                    SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 26,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          if (articleOnTop?.band != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    SwipeablePageRoute(
                                      builder: (context) => BandDetailsPage(
                                        band: articleOnTop?.band,
                                      ),
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                //margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800
                                      .withOpacity(0.35), //.withOpacity(0.8),
                                  //border: Border.all(color: Colors.grey.shade900.withOpacity(0.85),width: 2.5),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  articleOnTop?.band?.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                              child: Container(
                            height: 5,
                          )),
                          if (isBoosted)
                            Container(
                              padding: EdgeInsets.all(12),
                              child: Image.asset(
                                'images/boost_enabled.png', //'images/like_btn.png',
                                height: 28,
                                color: Colors.white,
                                fit: BoxFit.contain,
                              ),
                            )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void preloadNextPageImage(int nextPageIndex) async {
    if (_preloadedImages.length <= nextPageIndex) {
      final nextPageImageUrl =
          widget.preloadList?.elementAt(nextPageIndex)?.article?.imageUrl;
      if (nextPageImageUrl != null && nextPageImageUrl.isNotEmpty) {
        final preloadedImage = NetworkImage(nextPageImageUrl);
        precacheImage(preloadedImage, context);
        _preloadedImages.add(preloadedImage);
      }
    }
  }

  Future<void> _refreshData() async {
    // Simulate a delay
    setState(() {
      loaded = false;
    });
    getArticlesData(true);
    await Future.delayed(const Duration(seconds: 2));
    getBandDrumms();
    // Refresh your data
    //getNews();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
    return true;
  }

  Widget getNewsArticles() {
    return SafeArea(
      bottom: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderCurve + 2),
        child: Container(
          decoration:
              BoxDecoration(gradient: LinearGradient(colors: backgroundColor)),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  currentVisiblePageIndex = value;
                  print("Current page index is ${currentVisiblePageIndex}");
                  int boosts = 0;
                  DateTime currentTime = DateTime.now();
                  DateTime recent = currentTime.subtract(Duration(hours: 3));
                  Timestamp boostTime = Timestamp.now();
                  try {
                    boostTime = widget.preloadList
                            ?.elementAt(value)
                            .article!
                            .boostamp ??
                        Timestamp.now();
                    boosts =
                        widget.preloadList?.elementAt(value).article?.boosts ??
                            0;
                  } catch (e) {}
                  setState(() {
                    currentVisiblePageIndex = value;
                    articleOnTop = widget.preloadList?.elementAt(value);
                    isBoosted = (boosts > 0 &&
                        boostTime.compareTo(Timestamp.fromDate(recent)) > 0);
                  });

                  try {
                    FirebaseDBOperations.OggOpus_Player.pause();
                  } catch (e) {}
                  int articleSize = widget.preloadList?.length ?? 0;

                  print(
                      "Article size is $articleSize and current page is $value");

                  if (value >= articleSize - 2) {
                    getArticlesData(false);
                  }
                  //Prefetch the next page image
                  if (value != articleSize - 1) {
                    preloadNextPageImage(value + 1);
                  }
                },
                itemCount: widget.preloadList?.length,
                scrollDirection: Axis.vertical,
                physics: const CustomPageViewScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (!articleIDs.contains(widget.preloadList
                      ?.elementAt(index)
                      .article
                      ?.articleId)) {
                    articleIDs.add(widget.preloadList
                        ?.elementAt(index)
                        .article
                        ?.articleId);
                    checkIfUserLiked(index);
                  }

                  // if (widget.preloadList?.elementAt(index).article?.imageUrl ==
                  //     null) {
                  //   fetchMissingImageUrls(
                  //       widget.preloadList!.elementAt(index).article ??
                  //           Article(),
                  //       index);
                  //   imageSet.add(widget.preloadList
                  //           ?.elementAt(index)
                  //           .article
                  //           ?.articleId ??
                  //       "");
                  //   // print("Contains article ${artcls?.elementAt(index).articleId} ${imageSet.contains(artcls?.elementAt(index).articleId)}");
                  // }

                  Widget articleWidget = SafeArea(
                    bottom: false,
                    child: Hero(
                      tag: widget.preloadList
                              ?.elementAt(index)
                              .article
                              ?.articleId ??
                          "",
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 0),
                        fit: (isContainerVisible) ? BoxFit.cover : BoxFit.cover,
                        alignment: Alignment.topCenter,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        imageUrl: widget.preloadList
                                ?.elementAt(index)
                                .article
                                ?.imageUrl ??
                            "",
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          double opacity = downloadProgress.progress ?? 0;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.grey.shade900.withOpacity(0.25),
                              height: 300,
                              padding: const EdgeInsets.all(48),
                              child: Center(
                                child: SizedBox(
                                  width: 225,
                                  height: 225,
                                  child: (downloadProgress.progress == null)
                                      ? CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          color: Colors.white.withOpacity(0.07),
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors.white.withOpacity(0.07)),
                                        )
                                      : CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          color: Colors
                                              .white70, //.withOpacity(1.0-opacity),
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white70),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Container(
                              color: COLOR_BACKGROUND,
                              height: 300,
                              padding: const EdgeInsets.all(48),
                              child: Image.asset(
                                "images/drumm_logo.png",
                                color: Colors.white12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );

                  return Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          color: (isBoosted)
                              ? Colors.indigo.withOpacity(0.65)
                              : Colors.grey.shade900.withOpacity(0.8),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 320,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1,
                                              animation2) =>
                                          ZoomPicture(
                                              articleId: widget.preloadList
                                                  ?.elementAt(index)
                                                  .article
                                                  ?.articleId,
                                              url: widget.preloadList
                                                      ?.elementAt(index)
                                                      .article
                                                      ?.imageUrl ??
                                                  "https://placekitten.com/200/300"),
                                      transitionDuration:
                                          const Duration(seconds: 0),
                                      reverseTransitionDuration:
                                          const Duration(seconds: 0),
                                    ),
                                  );
                                },
                                child: articleWidget,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: FadeInContainer(
                                child: AutoSizeText(
                                  unescape.convert(widget.preloadList
                                          ?.elementAt(index)
                                          .article
                                          ?.meta
                                          ?.trim() ??
                                      widget.preloadList
                                          ?.elementAt(index)
                                          .article
                                          ?.title ??
                                      ""),
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: APP_FONT_MEDIUM,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 21,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Expanded(
                              flex: 8,
                              child: GestureDetector(
                                onTap: () {
                                  openArticlePage(
                                      widget.preloadList
                                          ?.elementAt(index)
                                          .article,
                                      index);
                                },
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: horizontalPadding),
                                        width: double.maxFinite,
                                        child: RawScrollbar(
                                          trackVisibility: true,
                                          interactive: true,
                                          child: SingleChildScrollView(
                                            physics: (!_scrollParent)
                                                ? ScrollPhysics()
                                                : NeverScrollableScrollPhysics(),
                                            child: ExpandableText(
                                              widget.preloadList
                                                      ?.elementAt(index)
                                                      .article
                                                      ?.summary
                                                      ?.trim() ??
                                                  "Read Article",
                                              textAlign: TextAlign.left,
                                              maxLines: 7,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white54,
                                                  fontFamily: APP_FONT_LIGHT,
                                                  fontWeight: FontWeight.w600),
                                              expandText: 'See more',
                                              linkColor: Colors.white,
                                              collapseText: 'Hide',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding),
                                      margin: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.preloadList
                                                            ?.elementAt(index)
                                                            .article
                                                            ?.source ??
                                                        "",
                                                    style: TextStyle(
                                                      color: Colors.white30,
                                                      fontSize: 13,
                                                      fontFamily:
                                                          APP_FONT_MEDIUM,
                                                    )),
                                                const Text(
                                                  " • ",
                                                  style: TextStyle(
                                                    color: Colors.white30,
                                                    fontSize: 13,
                                                    fontFamily: APP_FONT_MEDIUM,
                                                  ),
                                                ),
                                                InstagramDateTimeWidget(
                                                  publishedAt: widget
                                                          .preloadList
                                                          ?.elementAt(index)
                                                          .article
                                                          ?.publishedAt
                                                          .toString() ??
                                                      "",
                                                  textSize: 13,
                                                  fontColor: Colors.white30,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            GestureDetector(
                              onTap: () {
                                drumJoinDialog();
                              },
                              child: Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                                margin: EdgeInsets.fromLTRB(
                                    horizontalPadding - 6,
                                    0,
                                    horizontalPadding - 6,
                                    12),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  //color: Colors.blue,//s.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(borderCurve),
                                  //color: Colors.transparent,
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(CURVE),
                                  //   topRight: Radius.circular(CURVE),
                                  // ),
                                  gradient: LinearGradient(colors: JOIN_COLOR),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(
                                          'images/audio-waves.png',
                                          height: 24,
                                          color: Colors.white,
                                          fit: BoxFit.contain),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Container(
                                        // height: questionHeight,
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 4),
                                        child: Text(
                                          unescape.convert(
                                              "\"${widget.preloadList?.elementAt(index).article?.question ?? widget.preloadList?.elementAt(index).article?.title ?? ""}\"" ??
                                                  ""),
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: APP_FONT_LIGHT,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        // child:  RichText(
                                        //   text: TextSpan(
                                        //     text: unescape.convert(
                                        //       "\"${widget.preloadList?.elementAt(index).article?.question ?? widget.preloadList?.elementAt(index).article?.title??""}\"" ??
                                        //           ""),
                                        //     style: TextStyle(
                                        //         fontFamily: APP_FONT_LIGHT,
                                        //         color: Colors.white,
                                        //         fontWeight: FontWeight.w600,
                                        //         fontSize: 15),
                                        //     children: <TextSpan>[
                                        //       TextSpan(
                                        //         text: '  •  Drumm AI',
                                        //         style: TextStyle(
                                        //             fontFamily: APP_FONT_MEDIUM,
                                        //             color: Colors.white24,
                                        //             fontSize: 13),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                    //Text("  •  Drumm AI")
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getArticlesData(bool refresh) async {
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // List<String> userInterests = prefs.getStringList('interestList')!;
      // print("List of interests as per prefs $userInterests");
      List<dynamic> bandCategoryList = [];
      if (widget.selectedBandId == "For You") {
        List<Band> fetchedBands = await FirebaseDBOperations.getBandByUser();

        for (Band band in fetchedBands) {
          bandCategoryList.addAll(band.hooks ?? []);
        }
        if (fetchedBands.length < 1) bandCategoryList.add("general");
      } else if (widget.selectedBandId == "Boosted") {
        List<Band> fetchedBands = await FirebaseDBOperations.getBandByUser();

        for (Band band in fetchedBands) {
          bandCategoryList.addAll(band.hooks ?? []);
        }
        if (fetchedBands.length < 1) bandCategoryList.add("general");
      } else {
        Band selectedBand =
            await FirebaseDBOperations.getBand(widget.selectedBandId ?? "");
        bandCategoryList.addAll(selectedBand.hooks ?? []);
      }

      //print("Fetched interesets: ${userInterests.toString()}");
      print("Fetched categories: ${bandCategoryList.toString()}");

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('articles')
          .where('category', whereIn: bandCategoryList)
          .where('country', isEqualTo: 'in')
          .where('publishedAt', isNotEqualTo: null)
          .orderBy("publishedAt", descending: true)
          .limit(_pageSize);

      if (widget.selectedBandId == "Boosted") {
        DateTime currentTime = DateTime.now();
        DateTime oneDayAgo = currentTime.subtract(Duration(hours: 3));
        query = FirebaseFirestore.instance
            .collection('articles')
            .where('category', whereIn: bandCategoryList)
            .where('country', isEqualTo: 'in')
            .where('boostamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
            //.where('boosts', isGreaterThanOrEqualTo: 1)
            .orderBy("boostamp", descending: true)
            .limit(10);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        List<Article> newArticles =
            snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
        _lastDocument =
            snapshot.docs.last; // Save the last document for the next page

        //newArticles = await fetchMissingImageUrls(newArticles);

        List<ArticleBand> newArticlesBands = [];
        bandList = await FirebaseDBOperations.getBandByUser();

        for (Article article in newArticles) {
          for (Band band in bandList) {
            List hooks = band.hooks ?? [];
            if (hooks.contains(article.category)) {
              ArticleBand articleBand =
                  ArticleBand(article: article, band: band);
              newArticlesBands.add(articleBand);
              break;
            }
          }
        }

        List<ArticleBand> updatedArticles = [];

        if (refresh) {
          updatedArticles = newArticlesBands + articles;

          int boosts = 0;
          DateTime currentTime = DateTime.now();
          DateTime recent = currentTime.subtract(Duration(hours: 3));
          Timestamp boostTime = Timestamp.now();
          try {
            boostTime = widget.preloadList?.elementAt(0).article!.boostamp ??
                Timestamp.now();
            boosts = widget.preloadList?.elementAt(0).article?.boosts ?? 0;
          } catch (e) {}

          setState(() {
            articleOnTop = updatedArticles.elementAt(0);
            isBoosted = (boosts > 0 &&
                boostTime.compareTo(Timestamp.fromDate(recent)) > 0);
          });

          _articlesController.add(updatedArticles);
          //_pageController.jumpToPage(0);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              //do your stuff here
              _pageController.jumpToPage(0);
            }
          });
        } else {
          updatedArticles = articles + newArticlesBands;
          setState(() {
            //articleOnTop = updatedArticles.elementAt(0);
            widget.preloadList?.addAll(newArticlesBands);
          });
          //_articlesController.add(updatedArticles);
        }

        // print(
        //     "Current Channel Joined///////// ${newArticles.elementAt(0).title}");
        // if (autoJoinDrumms && !widget.userConnected) {
        //   ConnectToChannel.joinLiveDrumm(newArticles.elementAt(0), true);
        // }

        // Push the updated articles to Firestore
        //await updateFirestoreArticles(updatedArticles);

        // print('Fetched Articles: ${articles.length}');
      } else {
        print('Nothing found');
      }
      setState(() {
        loaded = true;
      });
    } catch (e) {
      // Handle any potential errors
      //print('Error fetching articles: ${e}');
      setState(() {
        loaded = true;
      });
    }
  }

  List<Article> filterArticle(List<Article> list) {
    List<Article> filtered = [];
    for (Article article in list) {
      if (article.source != null) {
        filtered.add(article);
      }
    }

    filtered = RemoveDuplicate.removeDuplicateArticles(filtered);

    return filtered;
  }

  void getToTop() {
    //getBandDrumms();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        //do your stuff here
        if (_pageController.page != 0) {
          //_lastDocument = null;
          _pageController
              .animateToPage(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
          )
              .then((value) {
            loadLatest = true;
          });

          // articles.clear();
        } else {
          if (loadLatest) {
            _lastDocument = null;
            articles.clear();
            _articlesController.add(articles);
            loadLatest = false;
          }
          _refreshData();

          // _pageController.animateToPage(0,
          //     duration: Duration(milliseconds: 250), curve: Curves.easeIn).then((value) {
          //
          // });
        }

        print("Jumping to top");
      }
    });
  }

  void jumpToArticle() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        //do your stuff here
        //if (_pageController.page != 0) {
        _pageController.jumpToPage(widget.articlePosition ?? 0);
        //}
      }
    });
    //_pageController.jumpToPage(widget.articlePosition??0);
  }

  Future<String?> fetchMissingImageUrls(Article article, int index) async {
    //List<String> apiKey = ["9a01f15daefa4b6288f9d9f6cb0ace8c","ce6a749e945141aea620c5d8dc22478d"];

    if (!imageSet.contains(article.articleId)) {
      if (article.imageUrl == null) {
        // print("Called index $index");
        String apiUrl =
            'https://api.worldnewsapi.com/extract-news?api-key=9a01f15daefa4b6288f9d9f6cb0ace8c&url=${article.url ?? ""}';
        try {
          var response = await http.get(Uri.parse(apiUrl));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            String imageUrl = data['image'];
            if (imageUrl != null) {
              article.imageUrl = imageUrl;
              setState(() {
                articles.elementAt(index).article?.imageUrl = imageUrl;
                _articlesController.add(articles);
              });
              // print('Image fetched $imageUrl');
              updateFirestoreArticle(article);
            }
          } else {
            //print(response.body);
          }
        } catch (e) {
          print('Error fetching image URL for article: $e');
        }
      }
    }

    return article.url;
  }

  updateFirestoreArticle(Article article) {
    Map<String, dynamic> imageMap() => {'imageUrl': article.imageUrl};
    FirebaseFirestore.instance
        .collection("articles")
        .doc(article.articleId)
        .set(imageMap(), SetOptions(merge: true));
  }

  void listenToJamState() {
    ConnectionListener.onConnectionChangedinVerticalHomeFeed =
        (connected, jam, open) {
      // Handle the channelID change here
      // print("onConnectionChanged called in Launcher");
      if (mounted)
        setState(() {
          // Update the UI with the new channelID
          openDrumm = open;
          currentJam = jam;
          showCurrentDrummWidget = connected;
        });
    };
  }

  bool _isDebouncing = false;

  void _handleScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent) {
      if (!_isDebouncing) {
        _isDebouncing = true;
        _currentPage++;
        // debugPrint("Current Page $_currentPage");
        getArticlesData(false);

        Timer(_debounceDuration, () {
          _isDebouncing = false;
        });
      }
    }
    final double itemExtent =
        100.0; // Adjust this value based on your item's height
    final int targetIndex = 4; // Index of the item you want to track

    final int firstVisibleIndex =
        (widget.scrollController.offset / itemExtent).floor();
    final int lastVisibleIndex = ((widget.scrollController.offset +
                widget.scrollController.position.viewportDimension) /
            itemExtent)
        .ceil();

    if (targetIndex >= firstVisibleIndex && targetIndex <= lastVisibleIndex) {
      // User has seen the target item
      // Handle your logic here
    }

    // print("Scroll Position changing ${widget.scrollController.position}");
  }

  void getPalette(String url) async {
    if (url.length < 1) {
      //setState(() {
      backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
      //});
      return;
    }
    try {
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        maximumColorCount: 3,
      ).catchError((e) {});
      List<Color> extractedColors = [];
      extractedColors.add((paletteGenerator.darkMutedColor != null)
          ? paletteGenerator.darkMutedColor?.color ?? COLOR_PRIMARY_DARK
          : (paletteGenerator.darkVibrantColor != null)
              ? paletteGenerator.darkVibrantColor?.color ?? COLOR_PRIMARY_DARK
              : (paletteGenerator.lightVibrantColor != null)
                  ? paletteGenerator.lightVibrantColor?.color
                          .withOpacity(0.5) ??
                      COLOR_PRIMARY_DARK
                  : (paletteGenerator.lightMutedColor != null)
                      ? paletteGenerator.lightMutedColor?.color
                              .withOpacity(0.5) ??
                          COLOR_PRIMARY_DARK
                      : (paletteGenerator.dominantColor != null)
                          ? paletteGenerator.dominantColor?.color
                                  .withOpacity(0.5) ??
                              COLOR_PRIMARY_DARK
                          : Colors.grey.shade900);
      extractedColors.add((paletteGenerator.dominantColor != null)
          ? paletteGenerator.dominantColor?.color.withOpacity(0.5) ??
              COLOR_PRIMARY_DARK
          : (paletteGenerator.lightMutedColor != null)
              ? paletteGenerator.lightMutedColor?.color.withOpacity(0.5) ??
                  COLOR_PRIMARY_DARK
              : (paletteGenerator.lightVibrantColor != null)
                  ? paletteGenerator.lightVibrantColor?.color
                          .withOpacity(0.5) ??
                      COLOR_PRIMARY_DARK
                  : (paletteGenerator.darkVibrantColor != null)
                      ? paletteGenerator.darkVibrantColor?.color ??
                          COLOR_PRIMARY_DARK
                      : (paletteGenerator.darkMutedColor != null)
                          ? paletteGenerator.darkMutedColor?.color ??
                              COLOR_PRIMARY_DARK
                          : Colors.grey.shade900);
      //extractedColors.add(paletteGenerator.darkMutedColor?.color??Colors.grey.shade900);
      //paletteGenerator.
      List<Color> opacityColor = paletteGenerator.colors.toList();
      //extractedColors.add(COLOR_PRIMARY_DARK);

      for (Color color in opacityColor) {
        //extractedColors.add(color.withOpacity(0.5));
      }

      if (extractedColors.length >= 2) {
        //setState(() {
        backgroundColor = extractedColors;
        //});
      } else {
        //setState(() {
        backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
        //});
      }
    } catch (e) {
      //setState(() {
      backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
      //});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // searchNewsAPI();
    //getNews();

    //searchHeadlinesAPI();

    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    initToken();
    _lastRefreshTime = DateTime.now();
    _lastDocument = widget.lastDocument;
    refreshFeed();

    _pageController = PageController(
      initialPage: widget.articlePosition ?? 0,
    );
    //_pageController.addListener(_pageListener);
    //widget.scrollController.addListener(_handleScroll);
    // _pageController.addListener(() {
    //   int initialPage = _pageController.initialPage;
    // });
    listenToJamState();
    getBandDrumms();
    getOpenDrumms();
    getCurrentDrummer();
  }

  void _pageListener() {
    //print("Pagecontroller page is ${_pageController.page}");
    if (_pageController.page == _pageController.page!.ceilToDouble()) {
      // Load more data

      //getArticlesData(false);
    }
  }

  void getBandsList() async {
    bandList = await FirebaseDBOperations.getBandByUser();
  }

  void _checkAndScheduleRefresh() {
    final now = DateTime.now();
    if (now.difference(_lastRefreshTime!) >= refreshInterval) {
      // Call your refresh() function if it hasn't been called within the refreshInterval
      refreshFeed();
      _lastRefreshTime = now;
    } else {
      // Calculate the remaining time until the next refresh and schedule the timer
      final remainingTime = refreshInterval - now.difference(_lastRefreshTime!);
      _startRefreshTimer(remainingTime);
    }
  }

  void refreshFeed() async {
    if (widget.preloadList == null) {
      // getArticlesData(true);
    } else {
      //List<Article> fetchedList = widget.preloadList ?? [];
      List<ArticleBand> fetchedArticleBand = widget.preloadList ?? [];
      bandList = await FirebaseDBOperations.getBandByUser();

      int boosts = 0;
      DateTime currentTime = DateTime.now();
      DateTime recent = currentTime.subtract(Duration(hours: 3));
      Timestamp boostTime = Timestamp.now();
      try {
        boostTime = widget.preloadList
                ?.elementAt(widget.articlePosition ?? 0)
                .article!
                .boostamp ??
            Timestamp.now();
        boosts = widget.preloadList
                ?.elementAt(widget.articlePosition ?? 0)
                .article
                ?.boosts ??
            0;
      } catch (e) {}

      setState(() {
        articleOnTop =
            fetchedArticleBand.elementAt(widget.articlePosition ?? 0);
        isBoosted =
            (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0);
        fromSearch = true;
        isContainerVisible = false;
        //_articlesController.add(fetchedArticleBand ?? []);
        print("Article position is ${widget.articlePosition}");
      });
      //jumpToArticle();
    }
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel(); // Stop the timer if it's active
  }

  void _startRefreshTimer(Duration duration) {
    _refreshTimer?.cancel(); // Cancel any existing timer
    _refreshTimer = Timer(duration, () {
      // Call your refresh() function when the timer fires
      refreshFeed();
      _lastRefreshTime = DateTime.now(); // Update the last refresh time
      _checkAndScheduleRefresh(); // Reschedule the next refresh
    });
  }

  void initToken() {
    requestPermissions();
    getToken();
    onNewToken();
  }

  void requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    print(notificationSettings.authorizationStatus);
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance
        .getToken(); //.then((value) => saveToken(value));
    saveToken(token);
  }

  saveToken(String? token) {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;

    print("Device Token: $token");
    Map<String, dynamic> tokenMap() => {'token': token};
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(tokenMap(), SetOptions(merge: true));
  }

  void onNewToken() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // Save newToken
      saveToken(newToken);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _articlesController.close();
    // widget.scrollController.removeListener(_handleScroll);
    widget.scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void checkIfUserLiked(int index) async {
    //  print("checkIfUserLiked called for index: $index");

    FirebaseDBOperations.hasBoosted(
            widget.preloadList?.elementAt(index).article?.articleId)
        .then((value) {
      setState(() {
        widget.preloadList?.elementAt(index).article?.liked = value;
        _articlesController.add(articles);
      });
    });
  }

  void openArticlePage(Article? article, int index) async {
    var returnData = await Navigator.push<Article?>(
      context,
      SwipeablePageRoute(
        builder: (context) => OpenArticlePage(
          article: article ?? Article(),
        ),
      ),
    );
    try {
      articles.elementAt(index).article = returnData!;
      _articlesController.add(articles);
    } catch (e) {}
    // print("Return Data ${returnData?.liked}");
  }

  Future<void> getBandDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getDrummsFromBands(); //getUserBands();
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    drumms = broadcastJams + fetchedDrumms;

    if (mounted) {
      setState(() {
        loaded = true;
        drummCards = drumms.map((jam) {
          return DrummCard(
            jam,
          );
        }).toList();

        print("drummCards returned");
        setState(() {
          loaded = true;
        });
      });
    }
  }

  Future<void> getOpenDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getOpenDrummsFromBands(); //getUserBands();
    openDrumms = fetchedDrumms;

    setState(() {
      openDrummCards = openDrumms.map((jam) {
        return DrummCard(
          jam,
          open: true,
        );
      }).toList();
    });
  }

  void joinOpenDrumm(ArticleBand aBand) {
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = aBand.article?.title;
    jam.bandId = aBand.band?.bandId;
    jam.jamId = aBand.article?.jamId;
    jam.articleId = aBand.article?.articleId;
    jam.startedBy = aBand.article?.source;
    jam.imageUrl = aBand.article?.imageUrl;
    if (aBand.article?.question != null) {
      jam.question = aBand.article?.question;
    } else {
      jam.question = aBand.article?.title;
    }
    jam.lastActive = Timestamp.now();
    jam.count = 0;
    jam.membersID = [];
    //FirebaseDBOperations.createOpenDrumm(jam);
    FirebaseDBOperations.addMemberToJam(aBand.article?.jamId ?? "",
            FirebaseAuth.instance.currentUser?.uid ?? "", true)
        .then((value) {
      print("Added the member ${value}");
      if (!value) {
        print("Creating drumm///////////////////////////////////////");
        FirebaseDBOperations.createOpenDrumm(jam);
      }

      FirebaseDBOperations.sendNotificationToTopic(jam, false, true);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: COLOR_PRIMARY_DARK,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(0.0)),
            child: JamRoomPage(
              jam: jam,
              open: true,
            ),
          ),
        );
      },
    );
  }

  void getCurrentDrummer() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    FirebaseDBOperations.getDrummer(uid).then((value) {
      setState(() {
        drummer = value;
      });
    });
  }

  void drumJoinDialog() {
    Vibrate.feedback(FeedbackType.selection);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DrummBottomDialog(
          articleBand: articleOnTop,
          startDrumming: () {
            ArticleBand? articleBand = ArticleBand();
            articleBand = articleOnTop;
            Vibrate.feedback(FeedbackType.success);
            joinOpenDrumm(articleBand ?? ArticleBand());
          },
        );
      },
    );
  }
}
