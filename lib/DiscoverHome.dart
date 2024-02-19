import 'dart:async';
import 'dart:collection';
import 'package:blur/blur.dart';
import 'package:drumm_app/MultiSelectContainerWidget.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/search_result_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/article_band.dart';
import 'package:drumm_app/model/band.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LiveIconWidget.dart';
import 'NotificationIconWidget.dart';
import 'UserProfileIcon.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/instagram_date_time_widget.dart';
import 'model/Drummer.dart';
import 'model/algolia_article.dart';
import 'model/article.dart';
import 'model/drumm_card.dart';
import 'model/jam.dart';
import 'user_profile_page.dart';

class DiscoverHome extends StatefulWidget {
  const DiscoverHome({Key? key}) : super(key: key);

  @override
  State<DiscoverHome> createState() => DiscoverHomeState();
}

class DiscoverHomeState extends State<DiscoverHome>
    with AutomaticKeepAliveClientMixin<DiscoverHome>, TickerProviderStateMixin {
  List<Article> articles = [];
  List<ArticleBand> articleBands = [];
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "For You";
  bool initialisedYoutubePlayer = false;
  List<dynamic> mAllSelectedItems = [];
  late MultiSelectContainerWidget multiSelectContainer;
  List<MultiSelectCard<dynamic>> bandsCards = [];
  Drummer drummer = Drummer();
  double horizontalPadding = 10;
  List<ArticleImageCard> articleCards = [];
  late String loadingAnimation;
  final String LOADING_ASSET = "images/pulse_white.json";
  final String NO_FOUND_ASSET = "images/caught_up.json";

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
  late OggOpusPlayer player;

  String audioFilePath = '';

  AlgoliaArticles? algoliaArticles;
  AlgoliaArticles? freshArticles;
  List<Article> freshArticleFetched = [];
  List<ArticleBand> fetchedArticleBand = [];

  HashMap<String, Band> bandMap = HashMap();

  String? queryID;
  String articleTop = "";
  late Article articleOnScreen;

  double multiSelectRadius = CURVE + 2;

  bool likedArticle = false;
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900; //COLOR_PRIMARY_DARK;
  double iconHeight = 58;
  double sizedBoxedHeight = 12;
  double curve = 26;

  int undoIndex = 0;

  int topIndex = 0;

  late Animation<double> slideAnimation;
  late Animation<double> rotationAnimation;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  DocumentSnapshot<Map<String, dynamic>>? _startDocument = null;

  List<Color> backgroundColor = JOIN_COLOR;
  List<DrummCard> drummCards = [];
  List<DrummCard> userDrummCards = [];
  List<Band> bands = [];
  List<Jam> drumms = [];
  bool loaded = false;

  bool showLiveALert = true;
  late ScrollController _scrollController;
  List<ArticleImageCard> loadingCards=[];

  List<ArticleImageCard> bufferingCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      body: SafeArea(
        bottom: false,
        top: true,
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: CustomScrollView(
            controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      vertical: 2, horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        // Build your content here
                        // Example:
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(
                                      color: Colors.grey.shade900, width: 2),
                                ),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserProfilePage(
                                              fromSearch: true,
                                            ),
                                          ));
                                    },
                                    child: UserProfileIcon(
                                      iconSize: 32,
                                    ))),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                          SearchResultPage(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: Wrap(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 9, horizontal: 16),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          //border: Border.all(color: Colors.grey.shade900),
                                          borderRadius: BorderRadius.circular(16)),
                                      child: Row(
                                        children: [
                                          Image.asset("images/search_button.png",
                                              color: Colors.white38, width: 16),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Text(
                                            "Search drumms",
                                            style: TextStyle(color: Colors.white38),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const LiveIcon(),
                            const SizedBox(
                              width: 8,
                            ),
                            const NotificationIcon(),
                          ],
                        );
                      },
                      childCount: 1, // Adjust the child count as per your content
                    ),
                  ),
                ),
                if (drummCards.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        vertical: 2, horizontal: 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          // Build your content here
                          // Example:
                          return Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                width: double.maxFinite,
                                child: const Text(
                                  "Live Drumms",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                height: 225,
                                child: PageView(
                                  scrollDirection: Axis.horizontal,
                                  children: drummCards,
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: 1, // Adjust the child count as per your content
                      ),
                    ),
                  ),
                SliverAppBar(
                  backgroundColor: COLOR_BACKGROUND.withOpacity(0.9),
                  floating: true,
                  pinned: true,
                  toolbarHeight: 102,
                  snap: true,
                  elevation: 10,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding),
                        width: double.maxFinite,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "What's new",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Expanded(child: Container()),
                            if (articleBands.isNotEmpty)
                              const Icon(Icons.refresh_rounded,
                                  size: 16, color: Colors.white38),
                            const SizedBox(
                              width: 2,
                            ),
                            if (articleBands.isNotEmpty)
                              const Text(
                                "Freshness",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white38),
                              ),
                            const SizedBox(
                              width: 4,
                            ),
                            if (articleBands.isNotEmpty)
                              InstagramDateTimeWidget(
                                  fontColor: Colors.white38,
                                  textSize: 12,
                                  publishedAt: articleBands
                                      .elementAt(0)
                                      .article
                                      ?.publishedAt
                                      .toString() ??
                                      ""),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (bandsCards.isNotEmpty)
                        Container(
                          //color: COLOR_BACKGROUND,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                            ),
                            height: 30,
                            child: multiSelectContainer),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              if(false)  Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      width: double.maxFinite,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "What's new",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Expanded(child: Container()),
                          if (articleBands.isNotEmpty)
                            const Icon(Icons.refresh_rounded,
                                size: 16, color: Colors.white38),
                          const SizedBox(
                            width: 2,
                          ),
                          if (articleBands.isNotEmpty)
                            const Text(
                              "Freshness",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white38),
                            ),
                          const SizedBox(
                            width: 4,
                          ),
                          if (articleBands.isNotEmpty)
                            InstagramDateTimeWidget(
                                fontColor: Colors.white38,
                                textSize: 12,
                                publishedAt: articleBands
                                    .elementAt(0)
                                    .article
                                    ?.publishedAt
                                    .toString() ??
                                    ""),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (bandsCards.isNotEmpty)
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                          ),
                          height: 30,
                          child: multiSelectContainer),
                    const SizedBox(height: 12),


                    GridView.custom(
                      shrinkWrap: true,
                      //controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 4,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: [
                          const QuiltedGridTile(2, 4),

                          const QuiltedGridTile(3, 2),
                          const QuiltedGridTile(2, 2),
                          const QuiltedGridTile(3, 2),
                          const QuiltedGridTile(2, 2),


                          const QuiltedGridTile(2, 4),

                          const QuiltedGridTile(2, 2),
                          const QuiltedGridTile(3, 2),
                          const QuiltedGridTile(3, 2),
                          const QuiltedGridTile(2, 2),

                        ],
                      ),
                      childrenDelegate: (articleCards.isNotEmpty)
                          ? SliverChildBuilderDelegate(
                        childCount: articleCards.length,
                            (context, index) =>
                            articleCards.elementAt(index),
                      )
                          : SliverChildBuilderDelegate(
                        childCount: 10,
                            (context, index) =>
                        //     Container(
                        //   decoration: BoxDecoration(
                        //       color: Colors.grey.shade900,
                        //       borderRadius:
                        //           BorderRadius.circular(16)),
                        // ),
                        loadingCards.elementAt(index),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      vertical: 2, horizontal: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        // Build your content here
                        // Example:
                        return GridView.custom(
                          shrinkWrap: true,
                          //controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverQuiltedGridDelegate(
                            crossAxisCount: 5,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            repeatPattern: QuiltedGridRepeatPattern.inverted,
                            pattern: [
                              // const QuiltedGridTile(2, 4),
                              //
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(2, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(2, 2),
                              //
                              //
                              // const QuiltedGridTile(2, 4),
                              //
                              // const QuiltedGridTile(2, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(3, 2),
                              // const QuiltedGridTile(2, 2),

                              const QuiltedGridTile(4, 3),
                              const QuiltedGridTile(3, 2),
                              const QuiltedGridTile(3, 2),
                              const QuiltedGridTile(2, 3),

                            ],
                          ),
                          childrenDelegate: (articleCards.isNotEmpty)
                              ? SliverChildBuilderDelegate(
                            childCount: articleCards.length,
                                (context, index) =>
                                articleCards.elementAt(index),
                          )
                              : SliverChildBuilderDelegate(
                            childCount: 10,
                                (context, index) =>
                            //     Container(
                            //   decoration: BoxDecoration(
                            //       color: Colors.grey.shade900,
                            //       borderRadius:
                            //           BorderRadius.circular(16)),
                            // ),
                            loadingCards.elementAt(index),
                          ),
                        );
                      },
                      childCount: 1, // Adjust the child count as per your content
                    ),
                  ),
                ),
              ],

          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      if (controller != null) controller?.dispose();
    } catch (e) {}

    if (FirebaseDBOperations.ANIMATION_CONTROLLER != null) {
      FirebaseDBOperations.ANIMATION_CONTROLLER.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    controller = CardSwiperController();
    super.initState();

    for(int i = 0;i<10;i++){
      loadingCards.add(ArticleImageCard(ArticleBand(),loading: false,));
    }


    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    ConnectToChannel.insights.userToken =
        FirebaseAuth.instance.currentUser?.uid ?? "";
    FirebaseDBOperations.lastDocument = null;
    getBandsCards();
    requestPermissions();

    getSharedPreferences();
    getBandDrumms();
  }
  void _scrollListener() {

    double threshold = 250.0; // Adjust as needed
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScrollPosition = _scrollController.position.pixels;
    double remainingScrollDistance = maxScrollExtent - currentScrollPosition;

    // Check if the remaining scroll distance is less than the threshold
    if (remainingScrollDistance < threshold && !_scrollController.position.outOfRange && bufferingCards.isEmpty) {
      // Scroll position is almost at the end
      // Call getArticles method to fetch more data
      bufferingCards = articleCards;
      setState(() {
        articleCards = articleCards + loadingCards;
      });
      if (selectedBandID == "For You") {
        getArticles(false);
      } else {
        getArticlesForBands(selectedBand, false);
      } // Pass true to fetch more articles
    }
  }
  void getToTop() {
    //getBandDrumms();
    print("Okay");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }
  void getBandsCards() async {
    mulList.clear();

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
        );
      }
    });

    setState(() {
      bandsCards = mulList;
      multiSelectContainer = getMultiSelectWidget(context);
    });
  }

  Future<void> getBandDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getDrummsFromBands(); //getUserBands();
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    drumms = broadcastJams + fetchedDrumms;
    userDrummCards = drumms.map((jam) {
      return DrummCard(
        jam,
      );
    }).toList();

    setState(() {
      drummCards = drummCards + userDrummCards;
      loaded = true;
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
            articles = [];
            bufferingCards = [];
            articleBands = [];
            articleCards = [];
            articlePage = 0;
            initialisedYoutubePlayer = false;
            if (selectedBandID == "For You") {
              getArticles(false);

            } else {
              getArticlesForBands(selectedBand, false);
            }
            getToTop();
          });
        },
        bandsCards: bandsCards);
  }

  void getArticles(bool reverse) async {
    //setState(() {
    //articles.clear();
    //articleBands.clear();
    //});
    controller = CardSwiperController();
    algoliaArticles = await FirebaseDBOperations.getArticlesData(
        _startDocument, _lastDocument, reverse);
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

      if (selectedBandID == "For You") {
        setState(() {
          Article article = fetchedArticleBand
              .elementAt(0)
              .article ?? Article();
          print("getArticles page $articlePage item ${article.title}");
          try {} catch (e) {}
          topIndex = 0;
          initialisedYoutubePlayer = false;
          loadAnimation = false;
          queryID = algoliaArticles?.queryID;
          loadingAnimation = LOADING_ASSET;
          articles = articles + articleFetched;
          articleBands = articleBands + fetchedArticleBand;
          articleCards = bufferingCards +
              fetchedArticleBand.map((article) =>
              ArticleImageCard(
                article,
                articleBands: articleBands,
              ))
              .toList();
          bufferingCards = [];
          undoIndex = 0;
          try {
            articleOnScreen = articleBands
                .elementAt(0)
                .article ?? Article();
            if (articleTop == "") {
              articleTop = articleBands
                  .elementAt(0)
                  .article
                  ?.articleId ?? "";
            }
          } catch (e) {
            print("Error setting Article $e");
          }
        });
      }
    }
  }

  void getArticlesForBands(Band selectedBand, bool reverse) async {
    //articles.clear();
    //articleBands.clear();
    controller = CardSwiperController();
    algoliaArticles = await FirebaseDBOperations.getArticlesDataForBand(
        _startDocument, _lastDocument, reverse, selectedBand);
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

      if (selectedBandID == selectedBand.bandId) {
        setState(() {
          loadAnimation = false;
          queryID = algoliaArticles?.queryID;
          loadingAnimation = LOADING_ASSET;
          articles = articleFetched;
          articleBands = articleBands + fetchedArticleBand;
          articleCards = bufferingCards + fetchedArticleBand
              .map((article) =>
              ArticleImageCard(
                article,
                articleBands: articleBands,
              ))
              .toList();
          bufferingCards = [];
          undoIndex = 0;
          topIndex = 0;
          initialisedYoutubePlayer = false;
          articleOnScreen = articleBands
              .elementAt(0)
              .article ?? Article();
          articleTop = articleBands
              .elementAt(0)
              .article
              ?.articleId ?? "";
        });
      }
    }
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

  void getSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    showDrumJoinConfirmation =
        sharedPref.getBool(CONFIRM_JOIN_SHARED_PREF) ?? true;
    showExploreArticlesAlert =
        sharedPref.getBool(ALERT_EXPLORE_ARTICLES_SHARED_PREF) ?? true;
  }
}
