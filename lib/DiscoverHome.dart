import 'dart:async';
import 'dart:collection';
import 'package:blur/blur.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/CommunityQuestionsPage.dart';
import 'package:drumm_app/MultiSelectContainerWidget.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/professionDetailsPage.dart';
import 'package:drumm_app/search_result_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
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
import 'live_drumms.dart';
import 'model/Drummer.dart';
import 'model/QuestionCard.dart';
import 'model/algolia_article.dart';
import 'model/article.dart';
import 'model/drumm_card.dart';
import 'model/jam.dart';
import 'model/question.dart';
import 'user_profile_page.dart';

class DiscoverHome extends StatefulWidget {
  VoidCallback? scrolled;
  DiscoverHome({Key? key, this.scrolled}) : super(key: key);

  @override
  State<DiscoverHome> createState() => DiscoverHomeState();
}

class DiscoverHomeState extends State<DiscoverHome>
    with
        AutomaticKeepAliveClientMixin<DiscoverHome>,
        TickerProviderStateMixin,
        WidgetsBindingObserver {
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
  double horizontalPadding = 8;

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
  bool showNewArticleWidget = false;

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
  List<Question> questions = [];
  List<QuestionCard> questionCards = [];
  bool loaded = false;

  bool showLiveALert = true;
  late ScrollController _scrollController;
  List<ArticleImageCard> loadingCards = [];

  List<ArticleImageCard> bufferingCards = [];
  late PageController _pageController;

  bool fetchedAllBoosted = false;

  Article? latestArticle;

  String boostedText = "";

  AlgoliaArticles fetchBoostedAlgoliaArticles = AlgoliaArticles();

  bool scrolled = false;

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
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: onRefresh,
                color: Colors.white,
                strokeWidth: 3,
                backgroundColor: Colors.grey.shade900.withOpacity(0.75),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                          color: Colors.grey.shade900,
                                          width: 2),
                                    ),
                                    child: GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           UserProfilePage(
                                          //         fromSearch: true,
                                          //       ),
                                          //     ));

                                          context.pushTransparentRoute(
                                            UserProfilePage(
                                              fromSearch: true,
                                            ),
                                            // ProfessionDetailsPage()
                                          );
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
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              SearchResultPage(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
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
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                  "images/search_button.png",
                                                  color: Colors.white38,
                                                  width: 16),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              const Text(
                                                "Search on Drumm...",
                                                style: TextStyle(
                                                  fontFamily: APP_FONT_MEDIUM,
                                                    color: Colors.white38),
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
                          childCount:
                              1, // Adjust the child count as per your content
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(top: 16),
                    ),
                    if (drummCards.isNotEmpty)
                      SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Build your content here
                              // Example:
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: COLOR_PRIMARY_DARK,
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
                                                      top:
                                                          Radius.circular(0.0)),
                                              child: LiveDrumms(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: horizontalPadding),
                                          child: const Text(
                                            "Live now",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    height: 225,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: PageView(
                                      controller: _pageController,
                                      scrollDirection: Axis.horizontal,
                                      pageSnapping: false,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      //padding: EdgeInsets.symmetric(horizontal: 4),
                                      children: drummCards,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              );
                            },
                            childCount:
                                1, // Adjust the child count as per your content
                          ),
                        ),
                      ),
                    if (questionCards.isNotEmpty)
                      SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Build your content here
                              // Example:
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: COLOR_PRIMARY_DARK,
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
                                                      top:
                                                          Radius.circular(0.0)),
                                              child: CommunityQuestionsPage(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: horizontalPadding),
                                          child: const Text(
                                            "From Community",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    height: 150,
                                    alignment: Alignment.centerLeft,
                                    child: ListView(
                                      controller: _pageController,
                                      scrollDirection: Axis.horizontal,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 4),
                                      children: questionCards,
                                    ),
                                  ),
                                ],
                              );
                            },
                            childCount:
                                1, // Adjust the child count as per your content
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Build your content here
                            // Example:
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding),
                                  width: double.maxFinite,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "What's new",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
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
                                              fontSize: 13,
                                              color: Colors.white38),
                                        ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      if (articleBands.isNotEmpty &&
                                          latestArticle != null)
                                        InstagramDateTimeWidget(
                                            fontColor: Colors.white38,
                                            textSize: 12,
                                            publishedAt: latestArticle
                                                    ?.publishedAt
                                                    .toString() ??
                                                articleBands
                                                    .elementAt(0)
                                                    .article
                                                    ?.publishedAt
                                                    .toString() ??
                                                ""),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          childCount:
                              1, // Adjust the child count as per your content
                        ),
                      ),
                    ),
                    SliverAppBar(
                      backgroundColor: COLOR_BACKGROUND.withOpacity(0.9),
                      floating: true,
                      pinned: true,
                      toolbarHeight: 58,
                      snap: true,
                      //elevation: 10,
                      surfaceTintColor: COLOR_BACKGROUND.withOpacity(0.9),
                      foregroundColor: COLOR_BACKGROUND.withOpacity(0.9),
                      automaticallyImplyLeading: false,
                      flexibleSpace: Column(
                        children: [
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
                          if (bandsCards.isEmpty)  Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            height: 30,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  //color: Colors.grey.shade900,
                                  //height: 8,
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: index == 0 ?70:128,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 2,bottom: 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            double articlePadding = 10;
                            return GridView.custom(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverQuiltedGridDelegate(
                                crossAxisCount: 5,
                                mainAxisSpacing: articlePadding,
                                crossAxisSpacing: articlePadding,
                                repeatPattern: QuiltedGridRepeatPattern.inverted,
                                pattern: [
                                 // // const QuiltedGridTile(3, 5),
                                 //  const QuiltedGridTile(4, 3),
                                 //  const QuiltedGridTile(2, 2),
                                 //  const QuiltedGridTile(3, 2),
                                 //  const QuiltedGridTile(3, 3),
                                 //  const QuiltedGridTile(2, 2),
                                 //  const QuiltedGridTile(3, 2),
                                 //  const QuiltedGridTile(3, 3),
                                 //  //const QuiltedGridTile(3, 5),
                                 //  const QuiltedGridTile(2, 2),
                                 //  const QuiltedGridTile(4, 3),
                                 //  const QuiltedGridTile(3, 2),
                                 //  const QuiltedGridTile(3, 3),
                                 //  const QuiltedGridTile(2, 2),
                                 //  const QuiltedGridTile(3, 3),
                                 //  const QuiltedGridTile(3, 2),

                                  ////////////////////////////

                                  const QuiltedGridTile(5, 3),
                                  const QuiltedGridTile(3, 2),
                                  const QuiltedGridTile(4, 2),
                                  const QuiltedGridTile(4, 3),
                                  const QuiltedGridTile(3, 2),
                                  const QuiltedGridTile(4, 3),
                                  const QuiltedGridTile(3, 2),
                                  //const QuiltedGridTile(3, 3),
                                  //const QuiltedGridTile(3, 5),
                                  // const QuiltedGridTile(2, 2),
                                  // const QuiltedGridTile(4, 3),
                                  // const QuiltedGridTile(3, 2),
                                  // const QuiltedGridTile(3, 3),
                                  // const QuiltedGridTile(2, 2),
                                  // const QuiltedGridTile(3, 3),
                                  // const QuiltedGridTile(3, 2),


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
                                          loadingCards.elementAt(index),
                                    ),
                            );
                          },
                          childCount:
                              1, // Adjust the child count as per your content
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 150,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.transparent,
                              COLOR_BACKGROUND
                            ])),
                  ),
                ),
              ),
              if (showNewArticleWidget)
              Container(
                width: double.maxFinite,
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showNewArticleWidget = false;
                      getToTop();

                      _lastDocument = null;
                      _startDocument = null;
                      fetchedAllBoosted = false;

                      if (selectedBandID == "For You") {
                        getArticles(false);
                      } else {
                        getArticlesForBands(selectedBand, false);
                      }
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      "New articles available",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    _pageController = PageController(
        // viewportFraction: 0.95,

        );
    controller = CardSwiperController();
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    for (int i = 0; i < 10; i++) {
      loadingCards.add(ArticleImageCard(
        ArticleBand(),
        loading: true,
      ));
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    ConnectToChannel.insights.userToken =
        FirebaseAuth.instance.currentUser?.uid ?? "";
    FirebaseDBOperations.lastDocument = null;
    getBandsCards();
    getArticles(false);
    requestPermissions();

    getSharedPreferences();
    getBandDrumms();
    getCommunityQuestion();
  }

  void _scrollListener() {
    double threshold = 250.0; // Adjust as needed
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScrollPosition = _scrollController.position.pixels;
    double remainingScrollDistance = maxScrollExtent - currentScrollPosition;

    // Check if the remaining scroll distance is less than the threshold
    //print("Scrolled up");
    if(!scrolled) {
      widget.scrolled!();
      scrolled = true;
    }
    if (remainingScrollDistance < threshold &&
        !_scrollController.position.outOfRange &&
        bufferingCards.isEmpty) {
      // Scroll position is almost at the end
      // Call getArticles method to fetch more data
      bufferingCards = articleCards;
      setState(() {
        articleCards = articleCards + loadingCards;
      });
      if (selectedBandID == "For You") {
        getArticles(false);
      } else if(selectedBandID == "Boosted"){
        getBoostedArticles(false);
      }
      else {
        getArticlesForBands(selectedBand, false);
      } // Pass true to fetch more articles
    }
  }

  void getToTop() {
    //getBandDrumms();
    print("Okay");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  Future<bool> getBandsCards() async {
    mulList.clear();

    bandList = await FirebaseDBOperations.getBandByUser();

    List<Article> articleFetched = [];

    for (Band band in bandList) {
      bandMap.putIfAbsent(band.bandId ?? "", () => band);
    }

    //getArticles(false);

    Band allBands = Band();
    allBands.name = "For You";
    allBands.bandId = "For You";
    bandList.insert(0, allBands);

    fetchBoostedAlgoliaArticles =
        await FirebaseDBOperations.getBoostedArticlesData(null, null, false);
    print("Size of boosted articles ${fetchBoostedAlgoliaArticles.articles!.length}");

    if (fetchBoostedAlgoliaArticles.articles!.isNotEmpty) {
      Band boostedBand = Band();
      boostedBand.name = "Boosted";
      boostedBand.bandId = "Boosted";
      bandList.insert(0, boostedBand);

      setState(() {
        boostedText = "• ${fetchBoostedAlgoliaArticles.articles!.length}";
      });
    }

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
      } else if (element.bandId == "Boosted") {
        mulList.add(
          MultiSelectCard(
            value: element,
            decorations: MultiSelectItemDecorations(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(32),
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            textStyles: const MultiSelectItemTextStyles(
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontFamily: APP_FONT_MEDIUM,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              disabledTextStyle: TextStyle(
                color: Colors.white70,
                fontFamily: APP_FONT_MEDIUM,
                fontSize: 13,
              ),
              textStyle: TextStyle(
                color: Colors.indigoAccent,
                fontFamily: APP_FONT_MEDIUM,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 6,),
                Container(
                  padding: const EdgeInsets.only(left: 4,top: 6,bottom: 4,right: 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'images/boost_enabled.png', //'images/like_btn.png',
                    height: 42,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
                Text(boostedText),
                const SizedBox(width: 6,),

              ],
            ),
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
    return true;
  }

  Future<bool> getBandDrumms() async {
    drummCards.clear();
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getDrummsFromBands(); //getUserBands();
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    drumms = broadcastJams + fetchedDrumms;
    userDrummCards = drumms.map((jam) {
      return DrummCard(
        width: MediaQuery.of(context).size.width*0.85,
        jam,
      );
    }).toList();

    setState(() {
      drummCards = drummCards + userDrummCards;
      loaded = true;
    });

    return true;
  }

  Future<bool> getCommunityQuestion() async {
    questionCards.clear();
    //getUserBands();
    questions = await FirebaseDBOperations.getQuestionsAsked();
    List<QuestionCard> fetchedQuestionCards = questions.map((question) {
      return QuestionCard(
        question: question,
        deleteCallback: (question) {
          getCommunityQuestion();
        },
      );
    }).toList();

    print("Questions list ${fetchedQuestionCards.length}");

    setState(() {
      questionCards = fetchedQuestionCards;
      loaded = true;
    });
    return true;
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
          fetchedAllBoosted = false;
          _scrollController.jumpTo(0);
          setState(() {
            articles = [];
            bufferingCards = [];
            articleBands = [];
            articleCards = [];
            articlePage = 0;
            initialisedYoutubePlayer = false;
            if (selectedBandID == "For You") {
              getArticles(false);
            } else if (selectedBandID == "Boosted") {
              getBoostedArticles(false);
            } else {
              getArticlesForBands(selectedBand, false);
            }
            setState(() {
              showNewArticleWidget = false;
            });
            //getToTop();
          });
        },
        bandsCards: bandsCards);
  }

  Future<bool> getArticles(bool reverse) async {
    //setState(() {
    //articles.clear();
    //articleBands.clear();
    //});
    controller = CardSwiperController();
    List<Article> articleFetched = [];
    // if (!fetchedAllBoosted) {
    //   algoliaArticles = await FirebaseDBOperations.getBoostedArticlesData(
    //       _startDocument, _lastDocument, reverse);
    //   for (Article article in algoliaArticles?.articles ?? []) {
    //     int boosts = article.boosts ?? 0;
    //     if (boosts > 0) articleFetched.add(article);
    //   }
    // } //await FirebaseDBOperations.getArticlesByBands();
    // if (articleFetched.length < 10) {
    //   if (!fetchedAllBoosted) {
    //     _lastDocument = null;
    //     _startDocument = null;
    //     fetchedAllBoosted = true;
    //   }
    algoliaArticles = await FirebaseDBOperations.getArticlesData(
        _startDocument, _lastDocument, reverse);
    setState(() {
      latestArticle = algoliaArticles?.articles?.elementAt(0);
    });

    articleFetched.addAll(algoliaArticles?.articles ?? []);
    // for (Article article in algoliaArticles?.articles ?? []) {
    //   int boosts = article.boosts ?? 0;
    //   if (boosts == 0) articleFetched.add(article);
    // }
    //articleFetched.addAll(algoliaArticles?.articles ?? []);
    // }

    if (_lastDocument == null)
      _startDocument = algoliaArticles?.getStartDocument();

    _lastDocument = algoliaArticles?.getLastDocument();

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
          Article article =
              fetchedArticleBand.elementAt(0).article ?? Article();
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
              fetchedArticleBand
                  .map((article) => ArticleImageCard(
                        article,
                        articleBands: articleBands,
                        lastDocument: _lastDocument,
                        selectedBandID: selectedBandID,
                      ))
                  .toList();
          bufferingCards = [];
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
      }
    }
    return true;
  }

  Future<bool> getBoostedArticles(bool reverse) async {
    //setState(() {
    //articles.clear();
    //articleBands.clear();
    //});
    controller = CardSwiperController();
    List<Article> articleFetched = [];
    algoliaArticles = await FirebaseDBOperations.getBoostedArticlesData(
        _startDocument, _lastDocument, reverse);
    articleFetched.addAll(algoliaArticles?.articles ?? []);
    // for (Article article in algoliaArticles?.articles ?? []) {
    //   int boosts = article.boosts ?? 0;
    //   if (boosts > 0) articleFetched.add(article);
    // }

    if (_lastDocument == null)
      _startDocument = algoliaArticles?.getStartDocument();

    _lastDocument = algoliaArticles?.getLastDocument();

    if (articleFetched.isEmpty) {
      setState(() {
        loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
        articleCards = bufferingCards;

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

      if (selectedBandID == "Boosted") {
        setState(() {
          Article article =
              fetchedArticleBand.elementAt(0).article ?? Article();
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
              fetchedArticleBand
                  .map((article) => ArticleImageCard(
                        article,
                        articleBands: articleBands,
                        lastDocument: _lastDocument,
                        selectedBandID: selectedBandID,
                      ))
                  .toList();
          bufferingCards = [];
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
      }
    }
    return true;
  }

  Future<bool> getArticlesForBands(Band selectedBand, bool reverse) async {
    //articles.clear();
    //articleBands.clear();
    controller = CardSwiperController();
    List<Article> articleFetched = [];
    // if (!fetchedAllBoosted) {
    //   algoliaArticles =
    //       await FirebaseDBOperations.getBoostedArticlesDataForBand(
    //           _startDocument, _lastDocument, reverse, selectedBand);
    //   for (Article article in algoliaArticles?.articles ?? []) {
    //     int boosts = article.boosts ?? 0;
    //     if (boosts > 0) articleFetched.add(article);
    //   }
    // }

    // if (articleFetched.length < 10) {
    //    if (!fetchedAllBoosted) {
    //      _lastDocument = null;
    //      _startDocument = null;
    //      fetchedAllBoosted = true;
    //    }
    algoliaArticles = await FirebaseDBOperations.getArticlesDataForBand(
        _startDocument, _lastDocument, reverse, selectedBand);
    setState(() {
      latestArticle = algoliaArticles?.articles?.elementAt(0);
    });

    articleFetched.addAll(algoliaArticles?.articles ?? []);
    // for (Article article in algoliaArticles?.articles ?? []) {
    //   int boosts = article.boosts ?? 0;
    //   if (boosts == 0) articleFetched.add(article);
    // }
    //  }

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
          articleCards = bufferingCards +
              fetchedArticleBand
                  .map((article) => ArticleImageCard(
                        article,
                        articleBands: articleBands,
                        selectedBandID: selectedBandID,
                        lastDocument: _lastDocument,
                      ))
                  .toList();
          bufferingCards = [];
          undoIndex = 0;
          topIndex = 0;
          initialisedYoutubePlayer = false;
          articleOnScreen = articleBands.elementAt(0).article ?? Article();
          articleTop = articleBands.elementAt(0).article?.articleId ?? "";
        });
      }
    }
    return true;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Call checkForNewArticles whenever the app is resumed
      print("On Resume Discover Home");
      checkFreshArticles();
      getBandDrumms();
      getCommunityQuestion();
      // checkForNewArticles();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call checkForNewArticles whenever dependencies change
    print("On Resume Discover Home didChangeDependencies");
    // Delay the call to checkForNewArticles to ensure the widget is fully attached
  }

  void checkFreshArticles() async {
    late AlgoliaArticles freshArticle;

    if (selectedBandID == "For You") {
      freshArticle =
          await FirebaseDBOperations.getArticlesData(null, null, false);
    } else {
      freshArticle = await FirebaseDBOperations.getArticlesDataForBand(
          null, null, false, selectedBand);
    }

    if (_startDocument?.data()!["articleId"] !=
        freshArticle?.getStartDocument()?.data()!["articleId"]) {
      print("New Articles fetched");
      setState(() {
        showNewArticleWidget = true;
      });
    }
  }

  Future<void> onRefresh() async {
    // Simulate fetching new data
    bool loadedCard = await getBandsCards();

    _lastDocument = null;
    _startDocument = null;
    fetchedAllBoosted = false;
    Vibrate.feedback(FeedbackType.selection);
    FirebaseDBOperations.lastDocument = null;
    controller = CardSwiperController();
    loadAnimation = false;
    loadingAnimation = LOADING_ASSET;
    selectedBandID = "For You";
    setState(() {
      articles = [];
      bufferingCards = [];
      articleBands = [];
      articleCards = [];
      articlePage = 0;
      initialisedYoutubePlayer = false;
    });

    bool loadedBand = await getBandsCards();
    bool loaded = await getArticles(false);
    bool loadedDrumms = await getBandDrumms();
    bool loadedQuestion = await getCommunityQuestion();

    setState(() {
      showNewArticleWidget = false;
    });
    //await Future.delayed(Duration(seconds: 2));
  }
}
