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
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/search_result_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:palette_generator/palette_generator.dart';
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
import 'UserProfileIcon.dart';
import 'article_jam_page.dart';
import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/create_jam_bottom_sheet.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/instagram_date_time_widget.dart';
import 'custom/rounded_button.dart';
import 'custom/transparent_slider.dart';
import 'jam_room_page.dart';
import 'model/Drummer.dart';
import 'model/algolia_article.dart';
import 'model/article.dart';
import 'model/drumm_card.dart';
import 'model/home_item.dart';
import 'model/home_item_default.dart';
import 'model/jam.dart';
import 'open_article_page.dart';
import 'user_profile_page.dart';

class DiscoverHome extends StatefulWidget {
  const DiscoverHome({Key? key}) : super(key: key);

  @override
  State<DiscoverHome> createState() => _DiscoverHomeState();
}

class _DiscoverHomeState extends State<DiscoverHome>
    with AutomaticKeepAliveClientMixin<DiscoverHome>, TickerProviderStateMixin {
  List<Article> articles = [];
  List<ArticleBand> articleBands = [];
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "For You";
  YoutubePlayerController youtubePlayerController = YoutubePlayerController(
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
  double horizontalPadding = 10;
  List<ArticleImageCard> articleCards = [];
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
  // List<Color> backgroundColor = [
  //   Colors.indigo,
  //   Colors.blue.shade700,
  //   //Colors.lightBlue,
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      body: SafeArea(
        bottom: false,
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          padding: const EdgeInsets.only(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 2, horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            border:
                                Border.all(color: Colors.grey.shade900, width: 2),
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
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          //padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                      SearchResultPage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Wrap(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      //border: Border.all(color: Colors.grey.shade900),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Row(
                                    children:  [
                                      Image.asset("images/search_button.png",color: Colors.white38,width: 16),
                                      SizedBox(width: 8,),
                                      Text("Search drumms",style: TextStyle(color: Colors.white38),)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      const LiveIcon(),
                      SizedBox(
                        width: 8,
                      ),
                      const NotificationIcon(),
                    ],
                  ),
                ),
                //if (articleBands.isNotEmpty)
                  Column(
                    children: [
                      if(drummCards.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            width: double.maxFinite,
                            child: Text(
                              "Live Drumms",
                              style:
                              TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 225,

                            child: PageView(
                              scrollDirection: Axis.horizontal,
                              //shrinkWrap: true,
                              children: drummCards,

                              //itemCount: drummCards.length,


                              // itemBuilder: (BuildContext context, int index) {
                              //   return Container(
                              //     //width: MediaQuery.of(context).size.width-50,
                              //     margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              //     //height: 200,
                              //     child: Stack(
                              //       children: [
                              //         ClipRRect(
                              //           borderRadius: BorderRadius.circular(CURVE),
                              //           child: CachedNetworkImage(
                              //             height: 200,
                              //             width: double.maxFinite,
                              //             imageUrl: articleBands
                              //                 .elementAt(index)
                              //                 .article
                              //                 ?.imageUrl ??
                              //                 "",
                              //             fit: BoxFit.cover,
                              //             errorWidget: (context, url, error) {
                              //               return Container(
                              //                 height: 0,
                              //                 width: double.infinity,
                              //                 //padding: const EdgeInsets.all(32),
                              //                 decoration: BoxDecoration(
                              //                   color: Colors.black,
                              //                   borderRadius: BorderRadius.only(
                              //                     topLeft: Radius.circular(CURVE),
                              //                     topRight: Radius.circular(CURVE),
                              //                   ),
                              //                 ),
                              //                 child: Image.asset(
                              //                   "images/logo_background_white.png",
                              //                   color: Colors.white.withOpacity(0.1),
                              //                 ),
                              //               );
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            width: double.maxFinite,
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "What's new",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                Expanded(child: Container()),
                                if(articleBands.isNotEmpty)
                                  Icon(Icons.refresh_rounded,size: 16,color: Colors.white54),
                                SizedBox(width: 2,),
                                if(articleBands.isNotEmpty)
                                Text(
                                  "Last Updated",
                                  style:
                                  TextStyle( fontSize: 13,color: Colors.white54),
                                ),
                                SizedBox(width: 6,),
                                if(articleBands.isNotEmpty)
                                InstagramDateTimeWidget(
                                  fontWeight: FontWeight.w700,
                                  textSize: 13,
                                    publishedAt: articleBands
                                        ?.elementAt(0).article?.publishedAt.toString() ??
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
                          const SizedBox(height: 16),
                          if (articleBands.isNotEmpty)
                            GridView.custom(
                              shrinkWrap: true,
                              //controller: _scrollController,
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverQuiltedGridDelegate(
                                crossAxisCount: 3,
                                mainAxisSpacing: 7,
                                crossAxisSpacing: 7,
                                repeatPattern: QuiltedGridRepeatPattern.inverted,
                                pattern: [
                                  //grid 1
                                  const QuiltedGridTile(1, 1),
                                  const QuiltedGridTile(2, 2),
                                  const QuiltedGridTile(1, 1),

                                  //grid 2
                                  const QuiltedGridTile(1, 2),
                                  const QuiltedGridTile(1, 1),
                                  const QuiltedGridTile(1, 1),
                                  const QuiltedGridTile(1, 2),

                                  //grid 3
                                  const QuiltedGridTile(2, 3),

                                  //grid 4
                                  const QuiltedGridTile(1, 1),
                                  const QuiltedGridTile(2, 2),
                                  const QuiltedGridTile(1, 1),

                                ],
                              ),
                              childrenDelegate: (articleCards.isNotEmpty)
                                  ? SliverChildBuilderDelegate(
                                childCount: articleCards.length,
                                    (context, index) => articleCards.elementAt(index),
                              )
                                  : SliverChildBuilderDelegate(
                                    (context, index) => Container(
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                // if (articleBands.isEmpty || loadAnimation)
                //   Container(
                //     height: double.maxFinite,
                //     width: double.maxFinite,
                //   ),


              ],
            ),
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
      getArticlesForBands(selectedBand, false);
      return;
    }
    getBandsCards();

    // Refresh your data
    //getNews();
  }

  void getPalette(String url) async {
    return;
    if (url.length < 1) {
      setState(() {
        backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
      });
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
        setState(() {
          backgroundColor = paletteGenerator.colors.toList(); //extractedColors;
        });
      } else {
        setState(() {
          backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
        });
      }
    } catch (e) {
      setState(() {
        backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
      });
    }
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
    } catch (e) {}

    if (FirebaseDBOperations.ANIMATION_CONTROLLER != null)
      FirebaseDBOperations.ANIMATION_CONTROLLER.dispose();

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
    getBandDrumms();
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
      //getOpenDrumms();
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
              getArticlesForBands(selectedBand, false);
            }
          });
        },
        bandsCards: bandsCards);
  }

  void openArticlePage(Article? article) async {
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

      setState(() {
        Article article = fetchedArticleBand.elementAt(0).article ?? Article();
        print("getArticles page $articlePage item ${article.title}");
        try {} catch (e) {}
        topIndex = 0;
        initialisedYoutubePlayer = false;
        playYoutubeVideo(article);
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        articleCards = articles
            .map((article) => ArticleImageCard(
          article,
          articles: articles,
        )).toList();
        undoIndex = 0;
        try {
          articleOnScreen = articleBands.elementAt(0).article ?? Article();
          if (articleTop == "") {
            articleTop = articleBands.elementAt(0).article?.articleId ?? "";
          }
        } catch (e) {
          print("Error setting Article $e");
        }
        getPalette(articleBands.elementAt(0).article?.imageUrl ?? "");
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

      setState(() {
        loadAnimation = false;
        queryID = algoliaArticles?.queryID;
        loadingAnimation = LOADING_ASSET;
        articles = articleFetched;
        articleBands = fetchedArticleBand;
        articleCards = articles
            .map((article) => ArticleImageCard(
          article,
          articles: articles,
        )).toList();
        undoIndex = 0;
        topIndex = 0;
        initialisedYoutubePlayer = false;
        articleOnScreen = articleBands.elementAt(0).article ?? Article();
        articleTop = articleBands.elementAt(0).article?.articleId ?? "";
        Article article = articleBands.elementAt(0).article ?? Article();
        playYoutubeVideo(article);
        getPalette(articleBands.elementAt(0).article?.imageUrl ?? "");
      });
    }
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
          if (!repeated) {
            FirebaseDBOperations.ANIMATION_CONTROLLER.forward();
          } else {
            FirebaseDBOperations.ANIMATION_CONTROLLER.dispose();
          }
          repeated = true;
        }
      });

    slideAnimation = Tween<double>(begin: 0.0, end: 10.0) // Slide movement
        .animate(CurvedAnimation(
            parent: FirebaseDBOperations.ANIMATION_CONTROLLER,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOutBack));
    rotationAnimation =
        Tween<double>(begin: 0.0, end: rotationEndDegree) // Rotation in degrees
            .animate(CurvedAnimation(
                parent: FirebaseDBOperations.ANIMATION_CONTROLLER,
                curve: Curves.easeInOut,
                reverseCurve: Curves.easeInOutBack));
  }

  void getSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    showDrumJoinConfirmation =
        sharedPref.getBool(CONFIRM_JOIN_SHARED_PREF) ?? true;
    showExploreArticlesAlert =
        sharedPref.getBool(ALERT_EXPLORE_ARTICLES_SHARED_PREF) ?? true;
  }
}
