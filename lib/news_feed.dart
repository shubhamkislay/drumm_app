import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:aws_polly/aws_polly.dart';
import 'package:blur/blur.dart';
import 'package:drumm_app/MultiSelectContainerWidget.dart';
import 'package:drumm_app/SkeletonHomeItem.dart';
import 'package:http/http.dart' as http;
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
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'ArticleDrummButton.dart';
import 'ExploreNewsButton.dart';
import 'JoinDrummButton.dart';
import 'LikeBtn.dart';
import 'LiveIconWidget.dart';
import 'NotificationIconWidget.dart';
import 'SwipeBackButton.dart';
import 'article_jam_page.dart';
import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
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
    with AutomaticKeepAliveClientMixin<NewsFeed>, TickerProviderStateMixin {
  List<Article> articles = [];
  List<ArticleBand> articleBands = [];
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "For You";
  YoutubePlayerController youtubePlayerController =  YoutubePlayerController(
    initialVideoId: YoutubePlayer.convertUrlToId(
        "https://www.youtube.com/watch?v=d8jFqvDn3o8") ??
        "d8jFqvDn3o8",
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
      controlsVisibleAtStart: false,
    ),
  );
  bool initialisedYoutubePlayer = false;
  List<dynamic> mAllSelectedItems = [];
  late MultiSelectContainerWidget multiSelectContainer;
  List<MultiSelectCard<dynamic>> bandsCards = [];
  Drummer drummer = Drummer();
  double horizontalPadding = 4;
  late String loadingAnimation;
  final String LOADING_ASSET = "images/pulse_white.json";
  final String NO_FOUND_ASSET = "images/caught_up.json";

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool loadAnimation = false;
  bool showDrumJoinConfirmation = true;
  bool showExploreArticlesAlert = true;

  String selectedBandID = "For You";

  double drummLogoSize = 30;
  double iconSpaces = 20;
  double textSize = 28;
  double marginHeight = 200;
  late List<Band> bandList;

  var keepAlive = true;
  String audioUrl = "";

  double iconSize = 30;
  int articlePage = 0;

  bool isOnboarded = false;
  bool isTutorialDone = false;

  Band selectedBand = Band();
  //final player = AudioPlayer();
  late OggOpusPlayer player;

  //AudioPlayer audioPlayer = AudioPlayer();
  //AudioCache audioCache = AudioCache();
  String audioFilePath = '';

  AlgoliaArticles? algoliaArticles;
  AlgoliaArticles? freshArticles;
  List<Article> freshArticleFetched = [];
  List<ArticleBand> fetchedArticleBand = [];

  HashMap<String, Band> bandMap = HashMap();

  String? queryID;
  String articleTop = "";
  late Article articleOnScreen;

  double multiSelectRadius = 12;

  bool likedArticle = false;
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900; //COLOR_PRIMARY_DARK;
  double iconHeight = 58;
  double sizedBoxedHeight = 12;
  double curve = 20;

  int undoIndex = 0;

  int topIndex = 0;

  late Animation<double> slideAnimation;
  late Animation<double> rotationAnimation;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  DocumentSnapshot<Map<String, dynamic>>? _startDocument = null;


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
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const LiveIcon(),
                    const SizedBox(
                      width: 4,
                    ),
                    if (bandsCards.isNotEmpty)
                      Expanded(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                              left: horizontalPadding - 2,
                              right: horizontalPadding + 2,
                            ),
                            height: 50,
                            child: multiSelectContainer),
                      ),
                    const NotificationIcon(),
                  ],
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              if (articleBands.isEmpty || loadAnimation)
                Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        const SkeletonHomeItem(),
                        if (articles.isEmpty && loadAnimation)
                          Center(
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 250,
                                  width: 250,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    //color: Colors.black,
                                    borderRadius: BorderRadius.circular(250),
                                    border: Border.all(
                                        color: Colors.transparent, width: 1),
                                  ),
                                  child: const Text(
                                    "You're all caught up",
                                    textAlign: TextAlign.center,
                                  ))),
                      ],
                    ),
                  ),
                ),
              if (articleBands.isNotEmpty)
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    fit: StackFit.loose,
                    children: [
                      AnimatedBuilder(
                        builder: (context,child) {// adjust slide value as needed
                          double slideValue = 50 * FirebaseDBOperations.ANIMATION_CONTROLLER.value;
                          // return Transform.translate(
                          //   offset: Offset(slideValue, 0.0), // Horizontal slide
                          //   child:

                          return  Transform.rotate(
                              angle: rotationAnimation.value * (2.417 / 180), // Convert to radians
                              origin: Offset(0, 1500), // Adjust as needed for rotation origin
                              child: child,
                            //),
                          );
                        }, animation: FirebaseDBOperations.ANIMATION_CONTROLLER,
                        child: Builder(
                          builder: (BuildContext context) {
                            try {
                              return CardSwiper(
                                controller: controller,
                                cardsCount: (articleBands.isNotEmpty)
                                    ? articleBands.length
                                    : 0,
                                duration: const Duration(milliseconds: 175),
                                maxAngle: 60,
                                scale: 0.8,
                                numberOfCardsDisplayed: (articleBands.length > 1)
                                    ? 2
                                    : (articleBands.isEmpty)
                                    ? 0
                                    : 1,
                                isVerticalSwipingEnabled: true,
                                onEnd: () {
                                  print("//////////////////////////On END");

                                  articlePage += 1;
                                  articleTop = "";
                                  if (selectedBandID == "For You") {
                                    getArticles(false);
                                  } else {
                                    getArticlesForBands(selectedBand,false);
                                  }
                                },
                                threshold: 25,
                                onSwipe: _onSwipe,
                                isLoop: false,
                                onUndo: _onUndo,
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                cardBuilder: (context, index) {
                                  try {
                                    if (index >= 0) {
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
                                          print("undoIndex ${undoIndex}");
                                          if (undoIndex != 0) {
                                            controller?.undo();
                                          } else {
                                            print("Cannot undo");
                                          }
                                        },
                                        onRefresh: () {
                                          return _refreshData();
                                        },
                                        index: index,
                                        joinDrumm: (articleBand) {
                                          startDrumming(articleBand);
                                        },
                                        play: false,
                                        youtubePlayerController:
                                        youtubePlayerController,
                                        onTop: topIndex == index,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } catch (e) {
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
                            left: 0, right: 0, top: 4, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SwipeBackButton(
                              controller: controller,
                              undoIndex: undoIndex,
                              fetchArticle: () {
                                if (articlePage != 0) {
                                  articlePage -= 1;

                                  setState(() {
                                    articleBands = [];
                                  });

                                  if (selectedBandID == "For You") {
                                    getArticles(true);
                                  } else {
                                    getArticlesForBands(selectedBand,true);
                                  }
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ExploreNewsButton(controller: controller),
                            const SizedBox(width: 4),
                            ArticleDrummButton(
                                articleOnScreen: articleOnScreen),
                            const SizedBox(width: 4),
                            JoinDrummButton(controller: controller),
                            const SizedBox(width: 8),
                            LikeBtn(
                                article: articleOnScreen,
                                queryID: queryID ?? ""),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
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
    if (selectedBandID != "For You") {
      getArticlesForBands(selectedBand,false);
      return;
    }
    getBandsCards();

    // Refresh your data
    //getNews();
  }

  startDrumming(ArticleBand articleBand) {
    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {
      //Vibrate.feedback(FeedbackType.heavy);
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900),
              child: Column(
                children: [
                  const Text(
                      "You are currently in a drumm already. Do you want to still join this drumm?"),
                  const SizedBox(
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
                        child: const Text(
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
                        child: const Text(
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
    try {
      if (controller != null) controller?.dispose();
    }catch(e){

    }

    if (FirebaseDBOperations.ANIMATION_CONTROLLER != null) FirebaseDBOperations.ANIMATION_CONTROLLER.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    controller = CardSwiperController();

    super.initState();

    initialiseSwipeAnimation();

    ConnectToChannel.insights.userToken =
        FirebaseAuth.instance.currentUser?.uid ?? "";
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    getBandsCards();
    requestPermissions();

    getSharedPreferences();

  }

  void getBandsCards() async {
    mulList.clear();
    //if(FirebaseDBOperations.fetchedBands.isEmpty) {
      bandList = await FirebaseDBOperations.getBandByUser();

    for (Band band in bandList) {
      bandMap.putIfAbsent(band.bandId ?? "", () => band);
    }
    getArticles(false);

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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 28,
                child: const Text(
                  "For You",
                  textAlign: TextAlign.center,
                )),
          ),
        );
      } else {
        String imageUrl = modifyImageUrl(element.url ?? "", "100x100");
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
                const SizedBox(
                  width: 8,
                ),
                Text("${element.name}")
              ],
            ),
          ),
          // MultiSelectCard(
          //   value: element,
          //   selected: false,
          //   child: Container(
          //       alignment: Alignment.center,
          //       padding: const EdgeInsets.symmetric(horizontal: 8),
          //       height: 28,
          //       child:  Text(
          //         "${element.name}",
          //         textAlign: TextAlign.center,
          //       )),
          // ),
        );
      }
    });

    setState(() {
      bandsCards = mulList;
      multiSelectContainer = getMultiSelectWidget(context);
    });
  }

  MultiSelectContainerWidget getMultiSelectWidget(BuildContext bContext) {
    return MultiSelectContainerWidget(
        onSelect: (selectedItems, selectedItem) {
          _lastDocument = null;
          _startDocument = null;
          Vibrate.feedback(FeedbackType.selection);
          FirebaseDBOperations.lastDocument = null;
          controller = CardSwiperController();
          loadAnimation = false;
          loadingAnimation = LOADING_ASSET;
          selectedBand = selectedItem;
          selectedBandID = selectedBand.bandId ?? "For You";
          setState(() {
            articlePage = 0;
            initialisedYoutubePlayer = false;
            //selectedCategory = selectedItem;
            if (selectedBandID == "For You") {
              getArticles(false);
            } else {
              getArticlesForBands(selectedBand,false);
            }
          });
        },
        bandsCards: bandsCards);
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
  }

  void getArticles(bool reverse) async {
    //setState(() {
    articles.clear();
    articleBands.clear();
    //});
    controller = CardSwiperController();
      algoliaArticles =
        await FirebaseDBOperations.getArticlesData(_startDocument,_lastDocument,reverse);
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();
    _lastDocument = algoliaArticles?.getLastDocument();
    _startDocument = algoliaArticles?.getStartDocument();

    if (articleFetched.isEmpty) {
      setState(() {
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
        Article article = fetchedArticleBand.elementAt(0).article ?? Article();
        print("getArticles page $articlePage item ${article.title}");
        try {

        } catch (e) {}
        topIndex = 0;
        initialisedYoutubePlayer = false;
        playYoutubeVideo(article);
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        undoIndex = 0;
        try {
          articleOnScreen = articleBands.elementAt(0).article ?? Article();
          if (articleTop == "") {
            articleTop = articleBands.elementAt(0).article?.articleId ?? "";
          }
        } catch (e) {
          print("Error setting Article $e");
        }
      });


      //  Article articleForSpeech = articleBands.elementAt(0).article?? Article();
      // // if(articleOnScreen.aiVoiceUrl==null)
      //    convertTextToSpeech(getSpeechText(articleForSpeech)??"No audio here",articleForSpeech.articleId??"");
      // else
      // speakNews(articleForSpeech.aiVoiceUrl);
    }
  }

  void getArticlesForBands(Band selectedBand, bool reverse) async {
    //setState(() {
    articles.clear();
    articleBands.clear();
    //});
    controller = CardSwiperController();
    // algoliaArticles =
    //     await FirebaseDBOperations.getArticlesByBandHookFromAlgolia(
    //         selectedBand, articlePage);
    algoliaArticles =
    await FirebaseDBOperations.getArticlesDataForBand(_startDocument,_lastDocument,reverse,
        selectedBand);
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();

    _lastDocument = algoliaArticles?.getLastDocument();
    _startDocument = algoliaArticles?.getStartDocument();

    List<ArticleBand> fetchedArticleBand = [];

    if (articleFetched.isEmpty) {
      setState(() {
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
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        undoIndex = 0;
        topIndex = 0;
        initialisedYoutubePlayer = false;
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
        articleTop = articleBands.elementAt(0).article?.articleId ?? "";
        Article article = articleBands.elementAt(0).article ?? Article();
        playYoutubeVideo(article);
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    //return true;
    undoIndex = currentIndex ?? 0;
    try {
      //audioPlayer.stop();
      FirebaseDBOperations.OggOpus_Player.pause();
      FirebaseDBOperations.OggOpus_Player.dispose();
    } catch (e) {}
    cleanCache();


    /**
     * Initialise and refersh youtube controller
     */
    if (currentIndex != null) {

      articleTop =
          articleBands.elementAt(currentIndex).article?.articleId ?? "";
      Article article =
          articleBands.elementAt(currentIndex).article ?? Article();
      print("onSwipe item ${article.title}");

      if(currentIndex == articleBands.length-1){
        youtubePlayerController = YoutubePlayerController(
          initialVideoId:
          YoutubePlayer.convertUrlToId(article?.url ?? "") ?? "",
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            loop: true,
            hideThumbnail: false,
            controlsVisibleAtStart: false,
          ),
        );
      }
      else {
        playYoutubeVideo(article);
      }

      setState(() {
          topIndex = currentIndex;
        });

    }

    try {
      player.dispose();
    } catch (e) {}
    setState(() {
      //undoIndex = currentIndex ?? 0;
      if (currentIndex != null) {
        articleOnScreen =
            articleBands.elementAt(currentIndex).article ?? Article();
      }
    });

    try {
      FirebaseDBOperations.updateSeen(
          articleBands.elementAt(previousIndex).article?.articleId);
    } catch (e) {}


    if (direction == CardSwiperDirection.top ||
        direction == CardSwiperDirection.bottom) return false;


    if (direction == CardSwiperDirection.left) {

      try {
        if(showExploreArticlesAlert) {
          Vibrate.feedback(FeedbackType.selection);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TutorialBox(
                boxType: BOX_TYPE_ALERT,
                sharedPreferenceKey: ALERT_EXPLORE_ARTICLES_SHARED_PREF,
                tutorialImageAsset: "images/google-earth.png",
                tutorialMessage: TUTORIAL_MESSAGE_EXPLORE,
                onConfirm: (){
                  showExploreArticlesAlert = false;
                  //joinOpenDrumm(articleBands.elementAt(previousIndex));
                  controller?.swipeLeft();
                }, tutorialMessageTitle: TUTORIAL_MESSAGE_EXPLORE_TITLE,
              );
            },
          );
          return false;
        }
        else{
          return true;
        }
      } catch (e) {
        return true;
      }

    }

    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {

      try {
        Vibrate.feedback(FeedbackType.selection);
        if(showDrumJoinConfirmation) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TutorialBox(
                boxType: BOX_TYPE_CONFIRM,
                sharedPreferenceKey: CONFIRM_JOIN_SHARED_PREF,
                tutorialImageAsset: "images/audio-waves.png",
                tutorialMessage: TUTORIAL_MESSAGE_JOIN,
                onConfirm: (){
                  showDrumJoinConfirmation = false;
                  //joinOpenDrumm(articleBands.elementAt(previousIndex));
                  controller?.swipeRight();
                }, tutorialMessageTitle: TUTORIAL_MESSAGE_JOIN_TITLE,
              );
            },
          );
          return false;
        }
        else{
          Vibrate.feedback(FeedbackType.success);
          joinOpenDrumm(articleBands.elementAt(previousIndex));
          return true;
        }
      } catch (e) {
        return false;
      }

    } else {
      showBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 200,
              width: double.maxFinite,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900),
              child: Column(
                children: [
                  const Text(
                      "You are currently in a drumm already. Do you want to still join this drumm?"),
                  const SizedBox(
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
                        child: const Text(
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
                        child: const Text(
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

  void playYoutubeVideo(Article article) {

    print("Playing youtube video ${article.title}");
    if (article.source?.toLowerCase() == 'youtube') {
      try {
        if (!initialisedYoutubePlayer) {
            youtubePlayerController = YoutubePlayerController(
              initialVideoId:
                  YoutubePlayer.convertUrlToId(article?.url ?? "") ?? "",
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
                loop: true,
                hideThumbnail: false,
                controlsVisibleAtStart: false,
              ),
            );
            initialisedYoutubePlayer = true;
        } else {
          print("Play the url:  ${article?.url}");
          youtubePlayerController
              .load(YoutubePlayer.convertUrlToId(article?.url ?? "") ?? "");
        }
      } catch (e) {
        print("Error playing video because $e");
      }
    }

  }

  // void playYoutube(Article article){
  //   if (article.source?.toLowerCase() == 'youtube') {
  //     try {
  //       if (!initialisedYoutubePlayer) {
  //         youtubePlayerController = YoutubePlayerController(
  //           onWebResourceError: (e){
  //             print("Error loading video beccause $e");
  //           },
  //
  //           params: YoutubePlayerParams(
  //             loop: true,
  //             mute: false,
  //             showControls: false,
  //             showVideoAnnotations: false,
  //             playsInline: true,
  //             showFullscreenButton: false,
  //           ),
  //         );
  //         youtubePlayerController.loadVideoById(videoId:convertUrlToId(article?.url ?? "")??"");
  //
  //         youtubePlayerController.listen((event) {
  //           print("Event: ${event}");
  //         },onError: (e){
  //           print("Error playing video because $e");
  //         });
  //         initialisedYoutubePlayer = true;
  //       } else {
  //         //youtubePlayerController.close();
  //         youtubePlayerController.loadVideoById(videoId:convertUrlToId(article?.url ?? "")??"").then((value) {
  //           print("Error playing video");
  //         },onError: (e){
  //           print("Error playing video because $e");
  //         });
  //       }
  //     } catch (e) {
  //       print("Error playing video because $e");
  //     }
  //   } else {
  //     // FirebaseDBOperations.youtubeController = YoutubePlayerController(
  //     //   initialVideoId: YoutubePlayer.convertUrlToId(
  //     //       "https://www.youtube.com/watch?v=d8jFqvDn3o8") ??
  //     //       "d8jFqvDn3o8",
  //     //   flags: const YoutubePlayerFlags(
  //     //     autoPlay: false,
  //     //     mute: false,
  //     //     controlsVisibleAtStart: false,
  //     //   ),
  //     // );
  //   }
  // }

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

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    undoIndex = currentIndex;
    setState(() {
      topIndex = currentIndex;
    });
    print("undo tapped ${currentIndex}");
    articleTop =
        articleBands.elementAt(currentIndex ?? 0).article?.articleId ?? "";
    Article article = articleBands.elementAt(currentIndex).article ?? Article();
    print("_onUndo item ${article.title}");

    if(previousIndex == articleBands.length-1){
      youtubePlayerController = YoutubePlayerController(
        initialVideoId:
        YoutubePlayer.convertUrlToId(article?.url ?? "") ?? "",
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
          hideThumbnail: false,
          controlsVisibleAtStart: false,
        ),
      );
    }
    else {
      playYoutubeVideo(article);
    }

    setState(() {
      //undoIndex = currentIndex;
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

    if (fetchcedArticle.isEmpty) {
      setState(() {
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
      if (!value) {
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

  void cleanCache() async {
    await DefaultCacheManager().emptyCache();
  }

  void requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
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

  Future speakNews(String? url) async {
    // await player.setUrl(url!).catchError((Onerr) {
    //   print("Error setting url : $Onerr");
    // });
    // player.play().catchError((Onerr) {
    //   print("Error playing : $Onerr");
    // });

    try {
      //await audioPlayer.play(UrlSource(url??""));
    } catch (e) {}
  }

  void initialiseSwipeAnimation() {
    bool repeated = false;
    double rotationEndDegree = 3.5;
    FirebaseDBOperations.ANIMATION_CONTROLLER = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,

    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        FirebaseDBOperations.ANIMATION_CONTROLLER.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if(!repeated) {

          FirebaseDBOperations.ANIMATION_CONTROLLER.forward();
        }
        else {
          FirebaseDBOperations.ANIMATION_CONTROLLER.dispose();
        }
        repeated = true;
      }
    });


    slideAnimation = Tween<double>(begin: 0.0, end: 10.0) // Slide movement
        .animate(CurvedAnimation(parent: FirebaseDBOperations.ANIMATION_CONTROLLER, curve: Curves.easeInOut,reverseCurve: Curves.easeInOutBack));
    rotationAnimation = Tween<double>(begin: 0.0, end: rotationEndDegree) // Rotation in degrees
        .animate(CurvedAnimation(parent: FirebaseDBOperations.ANIMATION_CONTROLLER, curve: Curves.easeInOut,reverseCurve: Curves.easeInOutBack));
  }

  void getSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    showDrumJoinConfirmation = sharedPref.getBool(CONFIRM_JOIN_SHARED_PREF)??true;
    showExploreArticlesAlert = sharedPref.getBool(ALERT_EXPLORE_ARTICLES_SHARED_PREF)??true;
  }
}
