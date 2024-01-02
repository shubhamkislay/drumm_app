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
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ArticleDrummButton.dart';
import 'ExploreNewsButton.dart';
import 'JoinDrummButton.dart';
import 'LikeBtn.dart';
import 'LiveIconWidget.dart';
import 'NotificationIconWidget.dart';
import 'SwipeBackButton.dart';
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
  late MultiSelectContainerWidget multiSelectContainer;
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

  double drummLogoSize = 30;
  double iconSpaces = 20;
  double textSize = 28;
  double marginHeight = 200;
  late List<Band> bandList;

  var keepAlive = true;
  String audioUrl = "";

  double iconSize = 30;

  bool isOnboarded = false;
  bool isTutorialDone = false;

  Band selectedBand = Band();
  //final player = AudioPlayer();
  late OggOpusPlayer player;

  AudioPlayer audioPlayer = AudioPlayer();
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

  double multiSelectRadius = 24;

  bool likedArticle = false;
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900; //COLOR_PRIMARY_DARK;
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
                      Center(
                        child: Lottie.asset(
                          "images/pulse_white.json", //loadingAnimation,
                          fit: BoxFit.contain,
                          width: double.maxFinite,
                        ),
                      ),
                      //if (!loadAnimation)
                      Center(
                        child: Container(
                            height: 275,
                            width: 275,
                            padding: const EdgeInsets.all(28),
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
                )),
              if (articleBands.isNotEmpty)
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    fit: StackFit.loose,
                    children: [
                      Builder(
                        builder: (BuildContext context) {
                          try {
                            return CardSwiper(
                              controller: controller,
                              cardsCount: (articleBands.isNotEmpty)
                                  ? articleBands.length
                                  : 0,
                              duration: const Duration(milliseconds: 175),
                              maxAngle: 45,
                              scale: 0.75,
                              numberOfCardsDisplayed: (articleBands.length > 1)
                                  ? 2
                                  : (articleBands.isEmpty)
                                      ? 0
                                      : 1,
                              isVerticalSwipingEnabled: false,
                              onEnd: () {
                                if (selectedBandID == "For You") {
                                  getArticles();
                                } else {
                                  getArticlesForBands(selectedBand);
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
                                        controller?.undo();
                                      },
                                      onRefresh: () {
                                        return _refreshData();
                                      },
                                      index: index,
                                      joinDrumm: (articleBand) {
                                        startDrumming(articleBand);
                                      },
                                      playPause: (article, listen) {
                                        try {
                                          player.pause();
                                          player.dispose();
                                        } catch (e) {}

                                        if (listen) {
                                          convertTextToSpeech(
                                              getSpeechText(article) ?? "",
                                              article.articleId ?? "");
                                        }
                                      },
                                      play: false,
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
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: double.maxFinite,
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 4, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SwipeBackButton(controller: controller),
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
    if (controller != null) controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    controller = CardSwiperController();

    super.initState();
    ConnectToChannel.insights.userToken =
        FirebaseAuth.instance.currentUser?.uid ?? "";
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    getBandsCards();
    requestPermissions();
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
        );
      }
    });

    setState(() {
      bandsCards = mulList;
      multiSelectContainer = getMultiSelectWidget(context);
    });
  }

  MultiSelectContainerWidget getMultiSelectWidget(BuildContext bContext) {
    return MultiSelectContainerWidget(onSelect: (selectedItems, selectedItem){
      Vibrate.feedback(FeedbackType.selection);
      FirebaseDBOperations.lastDocument = null;
      controller = CardSwiperController();
      loadAnimation = false;
      loadingAnimation = LOADING_ASSET;
      selectedBand = selectedItem;
      selectedBandID = selectedBand.bandId ?? "For You";
      setState(() {
        //selectedCategory = selectedItem;
        if (selectedBandID == "For You") {
          getArticles();
        } else {
          getArticlesForBands(selectedBand);
        }
      });
    }, bandsCards: bandsCards);
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

  void getArticles() async {
    //setState(() {
      articles.clear();
      articleBands.clear();
    //});
    controller = CardSwiperController();
    algoliaArticles = await FirebaseDBOperations.getArticlesFromAlgolia();
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();
    if (articleFetched.length < 1) {
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
        } catch (e) {}
      });

      //  Article articleForSpeech = articleBands.elementAt(0).article?? Article();
      // // if(articleOnScreen.aiVoiceUrl==null)
      //    convertTextToSpeech(getSpeechText(articleForSpeech)??"No audio here",articleForSpeech.articleId??"");
      // else
      // speakNews(articleForSpeech.aiVoiceUrl);
    }
  }

  void getArticlesForBands(Band selectedBand) async {
    //setState(() {
      articles.clear();
      articleBands.clear();
    //});
    controller = CardSwiperController();
    algoliaArticles =
        await FirebaseDBOperations.getArticlesByBandHookFromAlgolia(
            selectedBand);
    List<Article> articleFetched = algoliaArticles?.articles ??
        []; //await FirebaseDBOperations.getArticlesByBands();

    List<ArticleBand> fetchedArticleBand = [];

    if (articleFetched.length < 1) {
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
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    //return true;
    cleanCache();

    articleTop =
        articleBands.elementAt(currentIndex ?? 0).article?.articleId ?? "";

    Article articleForSpeech =
        articleBands.elementAt(currentIndex ?? 0).article ?? Article();
    try {
      player.dispose();
    } catch (e) {}
    setState(() {
      //undoIndex = currentIndex ?? 0;
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

  String? getSpeechText(Article articleForSpeech) {
    //return articleForSpeech.question;
    String? text = (articleForSpeech.description == null)
        ? articleForSpeech.title
        : "${articleForSpeech.description}";
    if (articleForSpeech.question != null) {
      text =
          "${text}\n${articleForSpeech.question}\nStart a drumm to check what the community thinks!";
    }
    return text;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    articleTop =
        articleBands.elementAt(currentIndex ?? 0).article?.articleId ?? "";
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

    if (fetchcedArticle.length < 1) {
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

  Future<void> convertTextToSpeech(String text, String id) async {
    try {
      player.pause();
      player.dispose();
    } catch (e) {}
    final apiKey = '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';
    final endpoint = 'https://api.openai.com/v1/audio/speech';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Define a list of voices
    final voices = [
      'alloy',
      'fable',
      'echo',
      'onyx',
      'nova',
      'shimmer'
    ]; //'echo', 'onyx', 'nova', 'shimmer'

    // Randomly select a voice from the list
    final random = Random();
    final selectedVoice = voices[random.nextInt(voices.length)];

    // Set the selected voice in the data
    final data = {
      'input': text,
      'model': 'tts-1',
      'voice': selectedVoice,
      'response_format': 'opus',
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      //  //await audioPlayer.play(BytesSource(response.bodyBytes));
      final audioBytes = response.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      final audioFile = File('${appDir.path}/${id}.opus');
      await audioFile.writeAsBytes(audioBytes);
      if (articleTop == id) {
        player = OggOpusPlayer(audioFile.path);
        player.play();
      }
    } else {
      // Handle API error
    }
  }
}
