import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:drumm_app/recommender.dart';
import 'package:drumm_app/skeleton_feed.dart';
import 'package:drumm_app/swipe_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:http/http.dart' as http;
import 'package:drumm_app/view_article_jams.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'custom/ai_summary.dart';
import 'custom/bottom_sheet.dart';
import 'custom/create_drumm_widget.dart';
import 'custom/helper/AudioChannelWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

String getCurrentUserID() {
  final User? user = FirebaseAuth.instance.currentUser;
  final String userID = user?.uid ?? '';
  return userID;
}

class HomeFeedPage extends StatefulWidget {
  HomeFeedPage(
      {Key? key,
      this.title,
      this.preloadList,
      this.themeManager,
      this.analytics,
      this.observer,
        required this.tag,
      required this.userConnected,
      required this.scrollController})
      : super(key: key);
  String? title;
  String tag;
  ThemeManager? themeManager;
  final ScrollController scrollController;
  FirebaseAnalytics? analytics;
  FirebaseAnalyticsObserver? observer;
  final bool userConnected;
  List<Article>? preloadList;
  @override
  HomeFeedPageState createState() => HomeFeedPageState();
}

class HomeFeedPageState extends State<HomeFeedPage>
    with
        AutomaticKeepAliveClientMixin<HomeFeedPage>,
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin {
  NewsModel newModel = NewsModel();
  NewsModel headlinesModel = NewsModel();
  List<Object> questionsAsked = [];
  List<Article> articles = [];
  PageController _pageController = PageController();
  List<NetworkImage> _preloadedImages = [];

  Set<String> imageSet = {};

  String summary = "Fetching summary from AI...";

  final Duration _debounceDuration = Duration(milliseconds: 100);

  HashSet<String?> articleIDs = HashSet();

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>();
  int _currentPage = 0;
  int _pageSize = 25;

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

  bool fromSearch =
      false;

  List<Jam> openDrumms = [];

  List<DrummCard> openDrummCards = []; //Colors.white.withOpacity(0.1); // Number of documents to fetch per page

  // Choose from any of these available methods

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool refreshList = true; // Set your desired refresh interval here


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_PRIMARY_DARK,
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isContainerVisible ? 275 : 0,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade800,width: 1)
              )
            ), // Apply app theme background color
            child: SafeArea(
              bottom: false,
              child: Transform.translate(
                offset: Offset(0, isContainerVisible ? 0 : 275),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                SpinKitPulsingGrid(
                                  color: Colors.red,
                                  size: 18.0,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                AutoSizeText(
                                  "Live",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (drummer != null)
                              Container(
                                height: 160,
                                padding: const EdgeInsets.only(
                                    left: 8, top: 8, bottom: 8),
                                child: CreateDrummWidget(
                                    drummer: drummer,
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: COLOR_PRIMARY_DARK,
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
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(0.0)),
                                              child: CreateJam(
                                                  title: "",
                                                  bandId: "",
                                                  imageUrl: ""),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                              ),
                            if (drummCards.length > 0)
                              Container(
                                height: 160,
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: drummCards.length,
                                    padding: EdgeInsets.all(8),
                                    itemBuilder: (context, index) =>
                                        drummCards.elementAt(index),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          width: 8,
                                        )),
                              ),
                            if (openDrummCards.length > 0)
                            Container(
                              height: 160,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: openDrummCards.length,
                                  padding: EdgeInsets.fromLTRB(0,8,8,8 ),
                                  itemBuilder: (context, index) =>
                                      openDrummCards.elementAt(index),
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 8,
                                      )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Listener(
              onPointerMove: (PointerMoveEvent event) {
                if (!fromSearch) {
                  if (event.delta.dy < 0) {
                    // Dragging upwards
                    setState(() {
                      isContainerVisible = false;
                    });
                  } else {
                    // Dragging downwards
                    setState(() {
                      getBandDrumms();
                      getOpenDrumms();
                      // if (drummCards.length > 0)
                      isContainerVisible = true;
                    });
                  }
                }
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                    ),
                    child: getArticles(), //listDemoVertical()),
                  ),
                  if (!isContainerVisible && !fromSearch)
                    DrummAppBar(
                      scrollController: widget.scrollController,
                      titleText: 'Drumm',
                      scrollOffset: 100,
                      isDark: true,
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => CreatePost(),
                        //   ),
                        // );

                        if (!autoJoinDrumms &&false)
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
                                  child: AutoJoinOption(optionCallback: (val) {
                                    setState(() {
                                      autoJoinDrumms = val;
                                      if (val && !widget.userConnected) {
                                        iconColor = Colors.white;
                                        ConnectToChannel.joinLiveDrumm(
                                            articles?.elementAt(
                                                    currentVisiblePageIndex) ??
                                                Article(),
                                            true);

                                        print(
                                            "Joining article title ${articles?.elementAt(currentVisiblePageIndex).title}");
                                      } else {
                                        autoJoinDrumms = false;
                                        iconColor =
                                            Colors.white.withOpacity(0.25);
                                      }
                                    });
                                  }),
                                ),
                              );
                            },
                          );
                        // else {
                        //   setState(() {
                        //     autoJoinDrumms = false;
                        //     iconColor = Colors.white.withOpacity(0.25);
                        //   });
                        // }
                      },
                      iconColor: iconColor,
                      autoJoinDrumms: autoJoinDrumms && !widget.userConnected,
                    ),
                  if(fromSearch)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void preloadNextPageImage(int nextPageIndex) async {
    if (_preloadedImages.length <= nextPageIndex) {
      final nextPageImageUrl = articles[nextPageIndex].imageUrl;
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
    await Future.delayed(Duration(seconds: 2));
    getBandDrumms();
    // Refresh your data
    //getNews();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
    return true;
  }

  Widget getArticles() {
    return StreamBuilder<List<Article>>(
      stream: _articlesController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return Center(
          //   child: const SizedBox(
          //     child: Text("No Articles present"),
          //   ),
          // );

          return SkeletonFeed();
        } else {
          if (!loaded) return SkeletonFeed();
          List<Article>? artcls = snapshot.data;
          artcls = RemoveDuplicate.removeDuplicateArticles(artcls!);
          articles = artcls!;

          // print("Size of the articles ${artcls.length}");

          return ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshData,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      currentVisiblePageIndex = value;
                      print(
                          "Page Changed/////////////////////// ${artcls?.elementAt(value).articleId}");
                      if (autoJoinDrumms && !widget.userConnected)
                        ConnectToChannel.joinLiveDrumm(
                            artcls?.elementAt(value) ?? Article(), true);
                      // setState(() {
                      //   setColor =
                      //       RandomColorBackground.generateRandomVibrantColor();
                      // });
                      if (value == articles.length - 1) {
                        getArticlesData(false);
                      }
                      //Prefetch the next page image
                      if (value != articles.length - 1)
                        preloadNextPageImage(value + 1);
                    },
                    itemCount: artcls?.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      if (!articleIDs
                          .contains(artcls?.elementAt(index).articleId)) {
                        articleIDs.add(artcls?.elementAt(index).articleId);
                        checkIfUserLiked(index);
                      }
                      //

                      //  print("${artcls?.elementAt(0).publishedAt}");
                      if (artcls?.elementAt(index).imageUrl == null) {
                        fetchMissingImageUrls(artcls!.elementAt(index), index);
                        imageSet.add(artcls?.elementAt(index).articleId ?? "");
                        // print("Contains article ${artcls?.elementAt(index).articleId} ${imageSet.contains(artcls?.elementAt(index).articleId)}");
                      }

                      //titleList![0] ?? "";

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 0),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                              imageUrl: artcls?.elementAt(index).imageUrl ?? "",
                              errorWidget: (context, url, error) {
                                //     Image.asset(
                                //   "images/logo_background_white.png",
                                //   color: Colors.grey.shade900
                                //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
                                //   width: 35,
                                //   height: 35,
                                // ),

                                return Container(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ),
                          Container(
                            height: double.maxFinite,
                            width: double.maxFinite,
                          ).frosted(
                              blur: 9,
                              frostColor: Colors.black), //COLOR_PRIMARY_DARK),
                          Positioned.fill(
                            child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 0),
                              fit:  (isContainerVisible) ? BoxFit.cover:BoxFit.fitWidth,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                              imageUrl: artcls?.elementAt(index).imageUrl ?? "",
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) {
                                return const LinearProgressIndicator(
                                  backgroundColor: Colors.black,
                                  color: Colors.black,
                                  // value: (downloadProgress.progress!=0)? downloadProgress.progress: 0,
                                );
                              },
                              errorWidget: (context, url, error) {
                                //     Image.asset(
                                //   "images/logo_background_white.png",
                                //   color: Colors.grey.shade900
                                //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
                                //   width: 35,
                                //   height: 35,
                                // ),

                                return Container(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ),
                          if (isContainerVisible&&false)
                            Container(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent
                                      ])),
                            ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isContainerVisible = false;
                                print("Tapped images!!!!!!!!");
                              });
                            },
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(
                                  left: 0, top: 100, right: 76, bottom: 44),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.6),
                                    Colors.black
                                        .withOpacity(0.85), //.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Vibrate.feedback(FeedbackType.light);
                                  openArticlePage(
                                      artcls?.elementAt(index), index);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: 120,
                                      padding: EdgeInsets.only(right: 0),
                                      child: FadeInContainer(
                                        child: Container(
                                          height: double.infinity,
                                          width: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 150,
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          //  color: Colors.black.withOpacity(0.20),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: FadeInContainer(
                                                child: AutoSizeText(
                                                  RemoveDuplicate
                                                      .removeTitleSource(artcls
                                                              ?.elementAt(index)
                                                              .title ??
                                                          ""),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 42,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              "Tap to view",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).frosted(
                                        blur: 8,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(4)),
                                        frostColor: Colors.grey
                                            .shade900, //Colors.grey.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 200,
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TyperAnimatedText(
                                    "${artcls?.elementAt(index).source} | ${artcls?.elementAt(index).category}",
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    speed: Duration(milliseconds: 35)),
                              ],
                              totalRepeatCount: 1,
                              repeatForever: false,
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 22,
                            child: InstagramDateTimeWidget(
                                publishedAt: artcls
                                        ?.elementAt(index)
                                        .publishedAt
                                        .toString() ??
                                    ""),
                          ),
                          Positioned(
                            right: 1,
                            bottom: 16,
                            child: Column(
                              children: [
                                RoundedButton(
                                  padding: 10,
                                  height: iconHeight,
                                  color:
                                      articles!.elementAt(index).liked ?? false
                                          ? Colors.red
                                          : Colors.white,
                                  bgColor: iconBGColor,
                                  hoverColor: Colors.redAccent,
                                  onPressed: () {
                                    setState(() {
                                      if (articles!.elementAt(index).liked ??
                                          false) {
                                        FirebaseDBOperations.removeLike(
                                            articles!
                                                .elementAt(index)
                                                .articleId);
                                        setState(() {
                                          articles!.elementAt(index).liked =
                                              false;
                                          int currentLikes = articles!
                                                  .elementAt(index)
                                                  .likes ??
                                              1;
                                          currentLikes -= 1;
                                          articles!.elementAt(index).likes =
                                              currentLikes;
                                          _articlesController.add(articles);
                                        });
                                      } else {
                                        FirebaseDBOperations.updateLike(
                                            articles!
                                                .elementAt(index)
                                                .articleId);
                                        setState(() {
                                          articles!.elementAt(index).liked =
                                              true;
                                          int currentLikes = articles!
                                                  .elementAt(index)
                                                  .likes ??
                                              0;
                                          currentLikes += 1;
                                          articles!.elementAt(index).likes =
                                              currentLikes;
                                          _articlesController.add(articles);
                                        });

                                        Vibrate.feedback(FeedbackType.impact);
                                      }
                                    });
                                  },
                                  assetPath:
                                      articles!.elementAt(index).liked ?? false
                                          ? 'images/liked.png'
                                          : 'images/heart.png',
                                ),
                                // if ((articles!.elementAt(index).likes ?? 0) > 0)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 2,
                                    ),
                                    if ((articles!.elementAt(index).likes ??
                                            0) >
                                        0)
                                      Text(
                                        "${articles!.elementAt(index).likes}",
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                  ],
                                ),
                                if (false)
                                  SizedBox(
                                    height: sizedBoxedHeight,
                                  ),
                                if (false)
                                  RoundedButton(
                                    padding: 12,
                                    height: 55,
                                    color: Colors.white,
                                    bgColor: Colors.grey.withOpacity(0.05),
                                    onPressed: () {},
                                    assetPath: 'images/chat.png',
                                  ),
                                if (false)
                                  SizedBox(
                                    height: sizedBoxedHeight,
                                  ),
                                if (false)
                                  RoundedButton(
                                    padding: 12,
                                    height: iconHeight,
                                    color: Colors.white,
                                    bgColor: iconBGColor,
                                    onPressed: () {
                                      openArticlePage(
                                          artcls?.elementAt(index), index);

                                      // print("Like status: ${artcls?[index].liked}");
                                    },
                                    assetPath: 'images/link.png',
                                  ),
                                // if ((articles!.elementAt(index).reads ?? 0) > 0)
                                if (false)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        ((articles!.elementAt(index).reads ??
                                                    0) >
                                                0)
                                            ? "${articles!.elementAt(index).reads}"
                                            : "Reads",
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  height: sizedBoxedHeight,
                                ),
                                RoundedButton(
                                  padding: 10,
                                  height: 52, //iconHeight,
                                  color: Colors.white,
                                  bgColor: iconBGColor,
                                  onPressed: () {
                                    AISummary.showBottomSheet(
                                        context,
                                        artcls!.elementAt(index) ?? Article(),
                                        Colors.transparent);
                                  },
                                  assetPath: 'images/sparkles.png',
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Text(
                                      "Summary",
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.transparent),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4, //sizedBoxedHeight,
                                ),
                                RoundedButton(
                                  padding: 10,
                                  height: 52, //iconHeight,
                                  color: Colors.white,
                                  bgColor: Colors.grey.shade600
                                      .withOpacity(0.30), //Colors.white24,
                                  onPressed: () {
                                    // AISummary.showBottomSheet(
                                    //     context,
                                    //     artcls!.elementAt(index) ?? Article(),
                                    //     Colors.transparent);
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
                                              article:
                                                  articles!.elementAt(index),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  assetPath: 'images/drumm_logo.png',
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "Drumms",
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                // ArticleChannel(
                                //   articleID:
                                //       artcls?.elementAt(index).articleId ?? "",
                                //   height: iconHeight,
                                // ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> getArticlesData(bool refresh) async {
    try {
     // SharedPreferences prefs = await SharedPreferences.getInstance();
     // List<String> userInterests = prefs.getStringList('interestList')!;
      // print("List of interests as per prefs $userInterests");
      List<Band> fetchedBands = await FirebaseDBOperations.getBandByUser();
      List<String> bandCategoryList = [];
      for (Band band in fetchedBands) {
        bandCategoryList.add(band.bandId ?? "");
      }
      if (fetchedBands.length < 1) bandCategoryList.add("general");

      //print("Fetched interesets: ${userInterests.toString()}");
      print("Fetched categories: ${bandCategoryList.toString()}");

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('articles')
          .where('category', whereIn: bandCategoryList)
          .where('country', isEqualTo: 'in')
          .where('source', isNotEqualTo: null)
          .orderBy("publishedAt", descending: true)
          .limit(_pageSize);

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

        List<Article> updatedArticles = [];

        if (refresh) {
          updatedArticles = newArticles + articles;

          _articlesController.add(filterArticle(updatedArticles));
          //_pageController.jumpToPage(0);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              //do your stuff here
              _pageController.jumpToPage(0);
            }
          });
        } else {
          updatedArticles = articles + newArticles;
          _articlesController.add(filterArticle(updatedArticles));
        }

        print(
            "Current Channel Joined///////// ${newArticles.elementAt(0).title}");
        if (autoJoinDrumms && !widget.userConnected) {
          ConnectToChannel.joinLiveDrumm(newArticles.elementAt(0), true);
        }

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
    getBandDrumms();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        //do your stuff here
        if (_pageController.page != 0) {
          //_lastDocument = null;
          _pageController
              .animateToPage(
            0,
            duration: Duration(milliseconds: 250),
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
                articles!.elementAt(index).imageUrl = imageUrl;
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

  @override
  void initState() {
    // TODO: implement initState
    // searchNewsAPI();
    //getNews();

    //searchHeadlinesAPI();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initToken();
    _lastRefreshTime = DateTime.now();
    refreshFeed();
    widget.scrollController.addListener(_handleScroll);
    // _pageController.addListener(() {
    //   int initialPage = _pageController.initialPage;
    // });
    //  listenToJamState();
    getBandDrumms();
    getOpenDrumms();
    getCurrentDrummer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      // Your code to react to app coming to the foreground in the HomeFeed widget
      _checkAndScheduleRefresh();

    } else {
      refreshList = true;
      _stopRefreshTimer(); // Stop the timer when the app goes to the background
    }
  }

  void _checkAndScheduleRefresh() {
    // AnimatedSnackBar.material(
    //     'Checking refresh',
    //     type: AnimatedSnackBarType.info,
    //     mobileSnackBarPosition: MobileSnackBarPosition.top
    // ).show(context);
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

  void refreshFeed(){
    if (widget.preloadList == null) {
      getArticlesData(true);
      // AnimatedSnackBar.material(
      //     'Refreshed List',
      //     type: AnimatedSnackBarType.success,
      //     mobileSnackBarPosition: MobileSnackBarPosition.top
      // ).show(context);
    }
    else {
      setState(() {
        fromSearch = true;
        isContainerVisible = false;
        _articlesController.add(widget.preloadList ?? []);
      });
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

    void listenToJamState() {
    ConnectionListener.onConnectionChanged = (connected, jam, open) {
      // Handle the channelID change here
      print("onConnectionChanged called in HomeFeed");
      setState(() {
        // Update the UI with the new channelID
        if (connected) {
          setState(() {
            autoJoinDrumms = false;
          });
        }
      });
    };
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
    widget.scrollController.removeListener(_handleScroll);
    widget.scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void checkIfUserLiked(int index) async {
    //  print("checkIfUserLiked called for index: $index");

    FirebaseDBOperations.hasLiked(articles.elementAt(index).articleId)
        .then((value) {
      setState(() {
        articles.elementAt(index).liked = value;
        _articlesController.add(articles);
      });
    });
  }

  void openArticlePage(Article? article, int index) async {
    var returnData = await Navigator.push<Article?>(
      context,
      MaterialPageRoute(
        builder: (context) => OpenArticlePage(
          article: article ?? Article(),
        ),
      ),
    );
    articles[index] = returnData!;
    _articlesController.add(articles);
    // print("Return Data ${returnData?.liked}");
  }

  Future<void> getBandDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getDrummsFromBands(); //getUserBands();
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    drumms = broadcastJams + fetchedDrumms;

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

  Future<void> getOpenDrumms() async {
    List<Jam> fetchedDrumms =
    await FirebaseDBOperations.getOpenDrummsFromBands(); //getUserBands();
    openDrumms =  fetchedDrumms;

    setState(() {
      openDrummCards = openDrumms.map((jam) {
        return DrummCard(
          jam,
          open: true,
        );
      }).toList();
    });
  }

  void openJamRoom(Jam jam,bool open){

    FirebaseDBOperations.sendNotificationToTopic(jam,false,open);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            child: JamRoomPage(jam: jam, open: open,),
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
}
