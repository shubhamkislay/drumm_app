import 'dart:async';
import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/live_drumms.dart';
import 'package:drumm_app/model/article_band.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
import 'package:drumm_app/notification_widget.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'article_jam_page.dart';
import 'custom/create_jam_bottom_sheet.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/rounded_button.dart';
import 'custom/transparent_slider.dart';
import 'jam_room_page.dart';
import 'model/Drummer.dart';
import 'model/algolia_article.dart';
import 'model/article.dart';
import 'model/home_item.dart';
import 'model/home_item_default.dart';
import 'model/jam.dart';
import 'open_article_page.dart';
import 'user_profile_page.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed>
    with AutomaticKeepAliveClientMixin<NewsFeed> {
  List<Article> articles = [];
  List<ArticleBand> articleBands = [];
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "For You";
  List<dynamic> mAllSelectedItems = [];
  late MultiSelectContainer multiSelectContainer;
  List<MultiSelectCard<dynamic>> bandsCards = [];
  Drummer drummer = Drummer();
  double horizontalPadding = 8;
  late String loadingAnimation;
  final String LOADING_ASSET = "images/pulse_white.json";
  final String NO_FOUND_ASSET = "images/caught_up.json";

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool loadAnimation = false;

  String selectedBandID = "For You";

  bool noArticlesPresent = false;
  bool liveDrummsExist = false;

  double drummLogoSize = 30;
  double iconSpaces = 26;
  double textSize = 28;
  double marginHeight = 200;
  late List<Band> bandList;

  var keepAlive = true;

  double iconSize = 30;

  bool isOnboarded = false;
  bool isTutorialDone = false;

  bool showNotification = false;

  Band selectedBand = Band();

  AlgoliaArticles? algoliaArticles;
  AlgoliaArticles? freshArticles;
  List<Article> freshArticleFetched = [];
  List<ArticleBand> fetchedArticleBand = [];

  HashMap<String, Band> bandMap = HashMap();

  String? queryID;
  String articleTop = "";
  late Article articleOnScreen;

  bool newArticlesAvailable = false;

  double multiSelectRadius = 18;

  bool likedArticle = false;
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900;//COLOR_PRIMARY_DARK;
  double iconHeight = 58;
  double sizedBoxedHeight = 12;
  double curve = 20;

  int undoIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 2, horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 4,
                    ),
                    if (false)
                      SizedBox(
                        height: drummLogoSize,
                        width: drummLogoSize,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Image.asset(
                            "images/logo_icon.png",
                            color: Colors.white,
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (false) Expanded(child: Container()),
                    if (true)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            "Drumm",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: drummLogoSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'alata',
                            ),
                          ),
                        ),
                      ),
                    if (false) Expanded(child: Container()),
                    SizedBox(
                      height: iconSize,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Vibrate.feedback(FeedbackType.selection);
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
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(0.0)),
                                      child: CreateJam(
                                          title: "", bandId: "", imageUrl: ""),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Image.asset(
                                  "images/edit.png",
                                  height: iconSize - 4,
                                  fit: BoxFit.contain,
                                  color: Colors.grey.shade200,
                                )),
                          ),
                          if (false)
                            SizedBox(
                              height: 2,
                            ),
                          if (false)
                            Flexible(
                                child: AutoSizeText(
                              "Live",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: iconSpaces,
                    ),
                    SizedBox(
                      height: iconSize,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Vibrate.feedback(FeedbackType.selection);
                              setState(() {
                                liveDrummsExist = false;
                                showNotification = false;
                              });
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
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(0.0)),
                                      child: NotificationWidget(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                child: Image.asset(
                                  showNotification
                                      ? "images/notification_active.png"
                                      : "images/notification_inactive.png",
                                  height: iconSize - 4,
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                )), //Icon(Icons.notifications_on_rounded,size: 32))),
                          ),
                          if (false)
                            SizedBox(
                              height: 2,
                            ),
                          if (false)
                            Flexible(
                                child: AutoSizeText(
                              "Live",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: iconSpaces,
                    ),
                    SizedBox(
                      height: iconSize,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Vibrate.feedback(FeedbackType.selection);
                              setState(() {
                                liveDrummsExist = false;
                              });
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
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(0.0)),
                                      child: LiveDrumms(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: (liveDrummsExist)
                                      ? LinearGradient(colors: [
                                          Colors.blue,
                                          Colors.blueAccent,
                                        ])
                                      : LinearGradient(colors: [
                                          Colors.grey.shade700,
                                          Colors.grey.shade700,
                                        ])),
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.black,
                                ),
                                // child: Icon(
                                //   Icons.data_saver_off_rounded,
                                //   size: iconSize - 4,
                                // ),
                                child: Image.asset(
                                  'images/drumm_logo.png',
                                  height: 20,
                                  color: Colors.white,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ), // data_saver_off_rounded Image.asset("images/hotspot.png",height: 24,fit: BoxFit.contain,color: Colors.white,))),
                          ),
                          if (false)
                            SizedBox(
                              height: 2,
                            ),
                          if (false)
                            Flexible(
                                child: AutoSizeText(
                              "Live",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: iconSpaces,
                    ),
                    GestureDetector(
                      onTap: () {
                        Vibrate.feedback(FeedbackType.selection);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(
                                drummer: drummer,
                                fromSearch: true,
                              ),
                            ));
                      },
                      child: Container(
                          width: iconSize - 4,
                          height: iconSize - 4,
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black),
                          child: (drummer.imageUrl != null)
                              ? Container(
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(19),
                                      color: Colors.black),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(17),
                                    clipBehavior: Clip.hardEdge,
                                    child: CachedNetworkImage(
                                        width: iconSize - 3,
                                        height: iconSize - 3,
                                        imageUrl: modifyImageUrl(
                                            drummer.imageUrl ?? "", "100x100"),
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : RoundedButton(
                                  height: 20,
                                  padding: 6,
                                  assetPath: "images/user_profile_active.png",
                                  color: Colors.white,
                                  bgColor: Colors.black,
                                  onPressed: () {})),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ),
              if (bandsCards.length > 0)
                SizedBox(
                  height: 4,
                ),
              if (bandsCards.length > 0)
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: horizontalPadding + 2,
                      right: horizontalPadding + 2,
                    ),
                    height: 50,
                    child: multiSelectContainer),
              SizedBox(
                height: 2,
              ),
              if (articleBands.length < 1 || loadAnimation)
                Expanded(
                    child: Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Lottie.asset(
                            "images/pulse_white.json", //loadingAnimation,
                            fit: BoxFit.contain,
                            width: double.maxFinite),
                      ),
                      //if (!loadAnimation)
                      Center(
                        child: Container(
                            height: 275,
                            width: 275,
                            padding: EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.black, //COLOR_PRIMARY_DARK,
                              borderRadius: BorderRadius.circular(275),
                            ),
                            child: Image.asset(
                              "images/logo_background_white.png",
                              color: (!loadAnimation)
                                  ? Colors.white.withOpacity(1)
                                  : Colors.white.withOpacity(0.05),
                              fit: BoxFit.contain,
                            )),
                      ),
                      if (articles.length < 1 && loadAnimation)
                        Center(
                            child: Container(
                                alignment: Alignment.center,
                                height: 250,
                                width: 250,
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  //color: Colors.black,
                                  borderRadius: BorderRadius.circular(250),
                                  border: Border.all(
                                      color: Colors.transparent, width: 1),
                                ),
                                child: Text(
                                  "You're all caught up",
                                  textAlign: TextAlign.center,
                                ))),
                    ],
                  ),
                )),
              if (articleBands.length > 0)
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    fit: StackFit.loose,
                    children: [
                      Container(
                        //padding: const EdgeInsets.only(bottom: 0),
                        child: Builder(
                          builder: (BuildContext context) {
                            try {
                              return CardSwiper(
                                controller: controller,
                                cardsCount: (articleBands.length > 0)
                                    ? articleBands.length
                                    : 0,
                                duration: Duration(milliseconds: 250),
                                maxAngle: 60,
                                scale: 0.8,
                                numberOfCardsDisplayed:
                                    (articleBands.length > 1)
                                        ? 2
                                        : (articleBands.length < 1)
                                            ? 0
                                            : 1,
                                isVerticalSwipingEnabled: false,
                                onEnd: () {
                                  print("Ended swipes");
                                  setState(() {
                                    //loadAnimation = true;
                                    //articles.clear();
                                  });

                                  if (selectedBandID == "For You")
                                    getArticles();
                                  else
                                    getArticlesForBands(selectedBand);
                                },
                                threshold: 25,
                                onSwipe: _onSwipe,
                                isLoop: false,
                                onUndo: _onUndo,
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                cardBuilder: (context, index) {
                                  print(
                                      "Index of element $index ${articles.elementAt(index).title}");
                                  try {
                                    if (index >= 0)
                                      return HomeItem(
                                        bandId: selectedBandID != "For You"
                                            ? selectedBandID
                                            : null,
                                        articleBand:
                                            articleBands.elementAt(index),
                                        queryID: queryID,
                                        isContainerVisible: false,
                                        openArticle: (article) {
                                          openArticlePage(article, index);
                                        },
                                        updateList: (article) {},
                                        undo: () {
                                          // setState(() {
                                          //   controller = CardSwiperController();
                                          // });

                                          controller?.undo();
                                        },
                                        onRefresh: () {
                                          return _refreshData();
                                        },
                                        index: index,
                                        joinDrumm: (articleBand) {
                                          startDrumming(articleBand);
                                        },
                                      );
                                    else
                                      return Container();
                                  } catch (e) {
                                    print(
                                        "//////////////////////////ERROR/////////////////////");
                                    return Container();
                                  }
                                },
                              );
                            } catch (e) {
                              return Container();
                            }
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: double.maxFinite,
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 4, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RoundedButton(
                              padding: 14,
                              height: iconHeight - 12, //iconHeight,
                              color: (undoIndex == 0 ) ? Colors.grey.shade600:Colors.deepOrange,
                              shadowColor: Colors.grey.shade800.withOpacity(0.2),
                              bgColor: iconBGColor, //.withOpacity(0.75),
                              onPressed: () {
                                Vibrate.feedback(FeedbackType.warning);
                                controller?.undo();
                              },
                              assetPath: 'images/turn-back.png',
                            ),
                            GestureDetector(
                              onTap: () {
                                Vibrate.feedback(FeedbackType.impact);
                                controller?.swipeLeft();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(42),
                                    border: Border.all(color: Colors.grey.shade800,width: 2.5)),
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(42),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade900,
                                          spreadRadius: 2,
                                          blurRadius: 4),
                                    ],
                                    // color: Color(COLOR_PRIMARY_VAL),//.withOpacity(0.95),
                                    gradient: LinearGradient(colors: [
                                      Colors.orange,
                                      Colors.red,
                                      Colors.pinkAccent,
                                      // Colors.grey.shade900,
                                      // Colors.grey.shade900,

                                    ]),
                                  ),
                                  // child: Icon(
                                  //   Icons.data_saver_off_rounded,
                                  //   size: iconSize - 4,
                                  // ),
                                  child: Lottie.asset(
                                    'images/globe_anim.json',
                                    height: 76,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            RoundedButton(
                              padding: 10,
                              height: iconHeight - 6, //iconHeight,
                              color: Colors.white,
                              bgColor: Colors.transparent,//Colors.grey
                                  //.shade900, //iconBGColor,//.withOpacity(0.75),
                              onPressed: () {
                                Vibrate.feedback(FeedbackType.selection);
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
                                          article: articleOnScreen,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              assetPath: 'images/drumm_logo.png',
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: () {
                                Vibrate.feedback(FeedbackType.impact);
                                controller?.swipeRight();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(42),
                                    border: Border.all(color: Colors.grey.shade800,width: 2.5)),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(42),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade900,
                                            spreadRadius: 2,
                                            blurRadius: 4),
                                      ],
                                      // color: Color(COLOR_PRIMARY_VAL),//.withOpacity(0.95),
                                      gradient: LinearGradient(colors: [
                                        Colors.indigo,
                                        Colors.blue.shade700,
                                        Colors.lightBlue,

                                      ]),
                                  ),
                                  // child: Icon(
                                  //   Icons.data_saver_off_rounded,
                                  //   size: iconSize - 4,
                                  // ),
                                  child: Lottie.asset(
                                    'images/wave_drumm.json',
                                    height: 52,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            RoundedButton(
                              padding: 12,
                              height: iconHeight - 12, //iconHeight,
                              //shadowColor: Colors.grey.shade800.withOpacity(0.75),
                              color: articleOnScreen.liked ?? false
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              bgColor: iconBGColor,
                              hoverColor: Colors.redAccent,
                              onPressed: () {
                                setState(() {
                                  if (articleOnScreen.liked ?? false) {
                                    FirebaseDBOperations.removeLike(
                                        articleOnScreen.articleId);
                                    articleOnScreen.liked = false;
                                    int currentLikes =
                                        articleOnScreen.likes ?? 1;
                                    currentLikes -= 1;
                                    articleOnScreen.likes = currentLikes;
                                    //  _articlesController.add(articles);
                                  } else {
                                    FirebaseDBOperations.updateLike(
                                        articleOnScreen.articleId);

                                    ConnectToChannel.insights
                                        .convertedObjectsAfterSearch(
                                      indexName: 'articles',
                                      eventName: 'Liked article',
                                      queryID: queryID ?? 'query id',
                                      objectIDs: [
                                        articleOnScreen.articleId ?? ""
                                      ],
                                    );

                                    articleOnScreen.liked = true;
                                    int currentLikes =
                                        articleOnScreen.likes ?? 0;
                                    currentLikes += 1;
                                    articleOnScreen.likes = currentLikes;
                                    //_articlesController.add(articles);

                                    Vibrate.feedback(FeedbackType.success);
                                  }
                                });
                              },
                              assetPath: articleOnScreen.liked ?? false
                                  ? 'images/liked.png'
                                  : 'images/like_btn.png',
                            ),

                            // if ((articles!.elementAt(index).likes ?? 0) > 0)
                          ],
                        ),
                      ),
                      if (newArticlesAvailable&&false)
                        GestureDetector(
                          onTap: () {
                            loadFreshArticles();
                            //getArticles();
                          },
                          child: Container(
                            width: 200,
                            height: 36,
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Text(
                              "News articles available",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate a delay
    // initState();
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    //controller = CardSwiperController();
    getCurrentDrummer();
    checkLiveDrumms();
    getNotifications();
    if(selectedBandID != "For You"){
      getArticlesForBands(selectedBand);
      return;
    }
    getBandsCards();

    // Refresh your data
    //getNews();
  }

  startDrumming(ArticleBand articleBand) {
    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {
      Vibrate.feedback(FeedbackType.heavy);
      try {
        joinOpenDrumm(articleBand);
      } catch (e) {}
      return true;
    } else {
      showBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 200,
              width: double.maxFinite,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900),
              child: Column(
                children: [
                  Text(
                      "You are currently in a drumm already. Do you want to still join this drumm?"),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          try {
                            joinOpenDrumm(articleBand);
                          } catch (e) {}
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          });
      return false;
    }
  }

  @override
  void dispose() {
    if (controller != null) controller?.dispose();
    //WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    controller = CardSwiperController();
    //WidgetsBinding.instance?.addObserver(this);
    super.initState();
    ConnectToChannel.insights.userToken =
        FirebaseAuth.instance.currentUser?.uid ?? "";
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    getBandsCards();
    getCurrentDrummer();
    checkLiveDrumms();
    getNotifications();
    requestPermissions();
  }


  void fetchFreshArticles() async {
    freshArticles = await FirebaseDBOperations.getArticlesFromAlgolia();

    freshArticleFetched = freshArticles?.articles ?? [];

    if (freshArticleFetched.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      for (Article article in freshArticleFetched) {
        for (Band band in bandList) {
          List hooks = band.hooks ?? [];
          if (hooks.contains(article.category)) {
            ArticleBand articleBand = ArticleBand(article: article, band: band);
            fetchedArticleBand.add(articleBand);
            break;
          }
        }
      }

      if (articleTop != fetchedArticleBand.elementAt(0).article?.articleId) {
        print("New articles available\nOld Article: ${articleTop}"
            "\nNew Article: ${fetchedArticleBand.elementAt(0).article?.articleId}");
        setState(() {
          newArticlesAvailable = true;
        });
      } else {
        // print("No news articles");
        print("No news articles\nOld Article: ${articleTop}"
            "\nNew Article: ${fetchedArticleBand.elementAt(0).article?.articleId}");
        setState(() {
          newArticlesAvailable = false;
        });
      }

      // setState(() {
      //   noArticlesPresent = false;
      //   loadAnimation = false;
      //   queryID = algoliaArticles?.queryID;
      //   loadingAnimation = LOADING_ASSET;
      //   articles = articleFetched;
      //   articleBands = fetchedArticleBand;
      //   print("Article length ${articles.length}");
      // });
    }
  }

  void loadFreshArticles() async {
    setState(() {
      articles.clear();
      articleBands.clear();
    });

    controller = CardSwiperController();

    Future.delayed(
      Duration(milliseconds: 500),
      () {
        setState(() {
          noArticlesPresent = false;
          loadAnimation = false;
          queryID = freshArticles?.queryID;
          loadingAnimation = LOADING_ASSET;
          articles = freshArticleFetched;
          articleBands = fetchedArticleBand;
          undoIndex = 0;
          articleOnScreen = articleBands.elementAt(0).article ?? Article();
          newArticlesAvailable = false;
          //   print("Article length ${articles.length}");
        });
      },
    );
  }

  void getNotifications() async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");

    int notifLen = notifications?.length ?? 0;

    if (notifLen > 0) {
      setState(() {
        showNotification = true;
      });
    }
  }

  void getBandsCards() async {
    mulList.clear();
    bandList = await FirebaseDBOperations.getBandByUser();
    for (Band band in bandList) {
      bandMap.putIfAbsent(band.bandId ?? "", () => band);
    }
      getArticles();


    Band allBands = Band();
    allBands.name = "For You";
    allBands.bandId = "For You";
    bandList.insert(0, allBands);
    bandList.forEach((element) {
      if (element.bandId == "For You") {
        mulList.add(
          MultiSelectCard(
            value: element,
            selected: true,
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 28,
                child: Text(
                  "For You",
                  textAlign: TextAlign.center,
                )),
          ),
        );
      } else {
        String imageUrl = modifyImageUrl(element.url ?? "", "100x100");
        print("The imageUrl is $imageUrl");
        mulList.add(
          MultiSelectCard(
            value: element,
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  width: 28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(multiSelectRadius),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text("${element.name}")
              ],
            ),
          ),
        );
      }
    });

    setState(() {
      bandsCards = mulList;
      multiSelectContainer = getMultiSelectWidget(context);
      print("bandsCards size ${bandsCards.length}");
    });
  }

  Future<void> checkLiveDrumms() async {
    List<Jam> fetchedDrumms = await FirebaseDBOperations.getDrummsFromBands();
    if (fetchedDrumms.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
      return;
    }
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    if (broadcastJams.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
    }
    List<Jam> openDrumms = await FirebaseDBOperations.getOpenDrummsFromBands();
    if (openDrumms.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
    }
  }

  MultiSelectContainer getMultiSelectWidget(BuildContext bContext) {
    return MultiSelectContainer(
      showInListView: true,
      listViewSettings: ListViewSettings(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(
          width: 5,
        ),
      ),
      suffix: MultiSelectSuffix(
          selectedSuffix: const Padding(
            padding: EdgeInsets.only(left: 1, right: 1),
          ),
          disabledSuffix: const Padding(
            padding: EdgeInsets.only(left: 1),
            child: Icon(
              Icons.do_disturb_alt_sharp,
              size: 14,
            ),
          )),
      controller: MultiSelectController(
        deSelectPerpetualSelectedItems: true,
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
            color: COLOR_PRIMARY_DARK, //Colors.grey.shade900,
            border:
                Border.all(color: Colors.grey.shade900,width: 2), //Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
        selectedDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white, //Colors.blue.shade600,
              Colors.white, //Colors.blue.shade800, //Colors.cyan,
            ]),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
      ),
      items: bandsCards,
      textStyles: MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold, // FontWeight.w700,
          fontFamily: "alata",
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold, // FontWeight.w700,
          fontFamily: "alata",
        ),
      ),
      onChange: (allSelectedItems, selectedItem) {
        Vibrate.feedback(FeedbackType.selection);
        FirebaseDBOperations.lastDocument = null;
        controller = CardSwiperController();
        setState(() {
          //selectedCategory = selectedItem;
          loadAnimation = false;
          loadingAnimation = LOADING_ASSET;
          selectedBand = selectedItem;
          selectedBandID = selectedBand.bandId ?? "For You";
          if (selectedBandID == "For You")
            getArticles();
          else
            getArticlesForBands(selectedBand);
        });
      },
      singleSelectedItem: true,
      itemsPadding: EdgeInsets.all(0),
    );
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
    setState(() {
      articles[index] = returnData!;
    });
    // print("Return Data ${returnData?.liked}");
  }

  void getArticles() async {
    setState(() {
      articles.clear();
      articleBands.clear();
    });
    controller = CardSwiperController();
    algoliaArticles = await FirebaseDBOperations.getArticlesFromAlgolia();
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();
    if (articleFetched.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      List<ArticleBand> fetchedArticleBand = [];
      for (Article article in articleFetched) {
        for (Band band in bandList) {
          List hooks = band.hooks ?? [];
          if (hooks.contains(article.category)) {
            ArticleBand articleBand = ArticleBand(article: article, band: band);
            fetchedArticleBand.add(articleBand);
            break;
          }
        }
      }

      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        undoIndex = 0;
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
        if (articleTop == "") {
          articleTop = articleBands.elementAt(0).article?.articleId ?? "";
        }
        print("Article length ${articles.length}");
      });
    }
  }

  void getArticlesForBands(Band selectedBand) async {
    setState(() {
      articles.clear();
      articleBands.clear();
    });
    controller = CardSwiperController();
    algoliaArticles =
        await FirebaseDBOperations.getArticlesByBandHookFromAlgolia(
            selectedBand);
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();

    List<ArticleBand> fetchedArticleBand = [];

    if (articleFetched.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      for (Article article in articleFetched) {
        ArticleBand articleBand =
            ArticleBand(article: article, band: selectedBand);
        fetchedArticleBand.add(articleBand);
      }

      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        undoIndex = 0;
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
        print("getArticlesForBands length ${articles.length}");
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    cleanCache();

    articleTop =
        articleBands.elementAt(currentIndex ?? 0).article?.articleId ?? "";
    setState(() {
      undoIndex = currentIndex??0;
      articleOnScreen =
          articleBands.elementAt(currentIndex ?? 0).article ?? Article();
    });

    try {
      FirebaseDBOperations.updateSeen(
          articleBands.elementAt(previousIndex).article?.articleId);
    } catch (e) {}

    if (direction == CardSwiperDirection.left) {
      Vibrate.feedback(FeedbackType.selection);

      return true;
    }

    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {
      Vibrate.feedback(FeedbackType.heavy);
      try {
        joinOpenDrumm(articleBands.elementAt(previousIndex));
      } catch (e) {}
      return true;
    } else {
      showBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 200,
              width: double.maxFinite,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900),
              child: Column(
                children: [
                  Text(
                      "You are currently in a drumm already. Do you want to still join this drumm?"),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          try {
                            joinOpenDrumm(
                                articleBands.elementAt(previousIndex));
                          } catch (e) {}
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          });
      return false;
    }

    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    articleTop =
        articleBands.elementAt(currentIndex ?? 0).article?.articleId ?? "";
    setState(() {
      undoIndex = currentIndex;
      articleOnScreen =
          articleBands.elementAt(currentIndex ?? 0).article ?? Article();
    });
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }

  void getArticlesForBand(Band bandSelected) async {
    setState(() {
      articles.clear();
      articleBands.clear();
    });
    controller = CardSwiperController();
    List<Article> fetchcedArticle =
        await FirebaseDBOperations.getArticlesByBandID(
            bandSelected.hooks ?? []);

    List<ArticleBand> fetchedArticleBand = [];

    if (fetchcedArticle.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      for (Article article in fetchcedArticle) {
        ArticleBand articleBand =
            ArticleBand(article: article, band: bandSelected);
        fetchedArticleBand.add(articleBand);
      }
      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        articles = fetchcedArticle;
        articleBands = fetchedArticleBand;
        undoIndex = 0;
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
        loadingAnimation = LOADING_ASSET;
      });
    }
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
    if(aBand.article?.question != null)
      jam.question = aBand.article?.question;
    else
      jam.question = aBand.article?.title;
    jam.lastActive = Timestamp.now();
    jam.count = 0;
    jam.membersID = [];
    //FirebaseDBOperations.createOpenDrumm(jam);
    FirebaseDBOperations.addMemberToJam(aBand.article?.jamId ?? "",
            FirebaseAuth.instance.currentUser?.uid ?? "", true)
        .then((value) {
      print("Added the member ${value}");
      if (!value) {
        FirebaseDBOperations.createOpenDrumm(jam);
      }

      FirebaseDBOperations.sendNotificationToTopic(jam, false, true);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: COLOR_PRIMARY_DARK,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            child: JamRoomPage(
              jam: jam,
              open: true,
            ),
          ),
        );
      },
    );
  }

  void getCurrentDrummer() async {
    Drummer curDrummer = await FirebaseDBOperations.getDrummer(
        FirebaseAuth.instance.currentUser?.uid ?? "");
    setState(() {
      drummer = curDrummer;
    });
  }

  void cleanCache() async {
    await DefaultCacheManager().emptyCache();
  }

  void requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission();
    print(notificationSettings.authorizationStatus);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => keepAlive;

  void _checkAndScheduleRefresh() {
    // AnimatedSnackBar.material(
    //     'Checking refresh',
    //     type: AnimatedSnackBarType.info,
    //     mobileSnackBarPosition: MobileSnackBarPosition.top
    // ).show(context);
    final now = DateTime.now();
    if (now.difference(_lastRefreshTime!) >= refreshInterval) {
      // Call your refresh() function if it hasn't been called within the refreshInterval
      keepAlive = false;
      _refreshData();
      _lastRefreshTime = now;
    } else {
      // Calculate the remaining time until the next refresh and schedule the timer
      final remainingTime = refreshInterval - now.difference(_lastRefreshTime!);
      _startRefreshTimer(remainingTime);
    }
  }

  void _stopRefreshTimer() {
    keepAlive = true;
    _refreshTimer?.cancel(); // Stop the timer if it's active
  }

  void _startRefreshTimer(Duration duration) {
    _refreshTimer?.cancel(); // Cancel any existing timer
    _refreshTimer = Timer(duration, () {
      // Call your refresh() function when the timer fires
      keepAlive = true;
      _lastRefreshTime = DateTime.now(); // Update the last refresh time
      _checkAndScheduleRefresh(); // Reschedule the next refresh
    });
  }

  void finishedTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTutorialDone = true;
    });
    await prefs.setBool('isTutorialDone', true);
  }
}
