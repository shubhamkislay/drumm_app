import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/live_drumms.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
import 'package:drumm_app/notification_widget.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/create_jam_bottom_sheet.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/rounded_button.dart';
import 'custom/transparent_slider.dart';
import 'jam_room_page.dart';
import 'model/Drummer.dart';
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
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "All";
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

  String selectedBandID = "All";

  bool noArticlesPresent = false;
  bool liveDrummsExist = false;

  double drummLogoSize = 30;
  double iconSpaces = 26;
  double textSize = 28;
  double marginHeight = 200;

  var keepAlive = true;

  double iconSize = 30;

  bool isOnboarded = false;
  bool isTutorialDone = false;

  bool showNotification = false;
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 2),
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
                                          title: "",
                                          bandId: "",
                                          imageUrl: ""),
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
                                padding: EdgeInsets.all(1.75),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: (liveDrummsExist)
                                        ? LinearGradient(colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade300,
                                          ])
                                        : LinearGradient(colors: [
                                            Colors.grey.shade900,
                                            Colors.grey.shade900,
                                          ])),
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(24),
                                      color: Colors.black,
                                    ),
                                    child: Icon(
                                      Icons.data_saver_off_rounded,
                                      size: iconSize - 4,
                                    ))), // data_saver_off_rounded Image.asset("images/hotspot.png",height: 24,fit: BoxFit.contain,color: Colors.white,))),
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
                                      borderRadius:
                                          BorderRadius.circular(19),
                                      color: Colors.black),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(17),
                                    clipBehavior: Clip.hardEdge,
                                    child: CachedNetworkImage(
                                        width: iconSize - 3,
                                        height: iconSize - 3,
                                        imageUrl: modifyImageUrl(
                                            drummer.imageUrl ?? "",
                                            "100x100"),
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : RoundedButton(
                                  height: 20,
                                  padding: 6,
                                  assetPath:
                                      "images/user_profile_active.png",
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
              if (articles.length < 1 || loadAnimation)
                Expanded(
                    child: Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Lottie.asset("images/pulse_white.json",//loadingAnimation,
                            fit: BoxFit.contain, width: double.maxFinite),
                      ),
                      if (!loadAnimation)
                        Center(
                          child: Container(
                              height: 250,
                              width: 250,
                              padding: EdgeInsets.all(54),
                              decoration: BoxDecoration(
                                color: COLOR_PRIMARY_DARK,
                                borderRadius: BorderRadius.circular(250),
                              ),
                              child: Image.asset(
                                "images/logo_background_white.png",
                                color: Colors.white,//.withOpacity(0.125),
                                fit: BoxFit.contain,
                              )),
                        ),
                       if (articles.length < 1 && loadAnimation)
                         Center(child:
                         Container(
                           alignment: Alignment.center,
                             height: 250,
                             width: 250,
                             padding: EdgeInsets.all(4),
                             decoration: BoxDecoration(
                               color: COLOR_PRIMARY_DARK,
                               borderRadius: BorderRadius.circular(250),
                               border: Border.all(
                                   color: Colors.transparent, width: 1),
                             ),
                             child: Text("You're all caught up",textAlign: TextAlign.center,))),
                    ],
                  ),
                )),
              if (articles.length > 0)
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      try {
                        return CardSwiper(
                          controller: controller,
                          cardsCount:
                              (articles.length > 0) ? articles.length : 0,
                          duration: Duration(milliseconds: 200),
                          maxAngle: 45,
                          scale: 0.85,
                          numberOfCardsDisplayed: (articles.length > 1)
                              ? 2
                              : (articles.length < 1)
                                  ? 0
                                  : 1,
                          isVerticalSwipingEnabled: false,
                          onEnd: () {
                            print("Ended swipes");
                            setState(() {
                              //loadAnimation = true;
                              //articles.clear();
                            });

                            if (selectedBandID == "All")
                              getArticles();
                            else
                              getArticlesForBand(selectedBandID);
                          },
                          threshold: 25,
                          onSwipe: _onSwipe,
                          isLoop: false,
                          onUndo: _onUndo,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          cardBuilder: (context, index) {
                            // print("Index of element $index");
                            try {
                              if (index >= 0)
                                return HomeItem(
                                  article: articles.elementAt(index),
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
    getBandsCards();
    getArticles();
    getCurrentDrummer();
    checkLiveDrumms();
    getNotifications();
    // Refresh your data
    //getNews();
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
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    getArticles();
    getBandsCards();
    getCurrentDrummer();
    checkLiveDrumms();
    getNotifications();
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
    List<Band> bandList = await FirebaseDBOperations.getBandByUser();
    Band allBands = Band();
    allBands.name = "All";
    allBands.bandId = "All";
    bandList.insert(0, allBands);
    bandList.forEach((element) {
      if (element.bandId == "All") {
        mulList.add(
          MultiSelectCard(
            value: element,
            selected: true,
            child: Container(
              alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 28,
                child: Text("All",textAlign: TextAlign.center,)),
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
                    borderRadius: BorderRadius.circular(13),
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
                Border.all(color: Colors.grey.shade900), //Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(18)),
        selectedDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white, //Colors.blue.shade600,
              Colors.white, //Colors.blue.shade800, //Colors.cyan,
            ]),
            borderRadius: BorderRadius.circular(18)),
      ),
      items: bandsCards,
      textStyles: MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'alata',
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'alata',
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
          Band selectedBand = selectedItem;
          print("Selected Band ID: ${selectedBand.bandId}");

          selectedBandID = selectedBand.bandId ?? "All";
          if (selectedBandID == "All")
            getArticles();
          else
            getArticlesForBand(selectedBandID);
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
    });
    controller = CardSwiperController();
    List<Article> articleFetched =
        await FirebaseDBOperations.getArticlesByBands();
    if (articleFetched.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        print("Article length ${articles.length}");
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    cleanCache();
    if (direction == CardSwiperDirection.left) {
      Vibrate.feedback(FeedbackType.selection);
      try {
        FirebaseDBOperations.updateSeen(
            articles.elementAt(previousIndex).articleId);
      } catch (e) {}
      return true;
    }

    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {
      Vibrate.feedback(FeedbackType.heavy);
      try {
        joinOpenDrumm(articles.elementAt(previousIndex));
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
                            joinOpenDrumm(articles.elementAt(previousIndex));
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
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }

  void getArticlesForBand(String bandID) async {
    setState(() {
      articles.clear();
    });
    controller = CardSwiperController();
    List<Article> fetchcedArticle =
        await FirebaseDBOperations.getArticlesByBandID(bandID);

    if (fetchcedArticle.length < 1) {
      setState(() {
        noArticlesPresent = true;
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });
    } else {
      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        articles = fetchcedArticle;
        loadingAnimation = LOADING_ASSET;
      });
    }
  }

  void joinOpenDrumm(Article article) {
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = article.title;
    jam.bandId = article.category;
    jam.jamId = article.jamId;
    jam.articleId = article.articleId;
    jam.startedBy = article.source;
    jam.imageUrl = article.imageUrl;
    jam.count = 0;
    jam.membersID = [];
    //FirebaseDBOperations.createOpenDrumm(jam);
    FirebaseDBOperations.addMemberToJam(
            jam.jamId ?? "", FirebaseAuth.instance.currentUser?.uid ?? "", true)
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
