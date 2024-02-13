import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:expandable_text/expandable_text.dart';
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
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'ArticleDrummButton.dart';
import 'BottomJamWindow.dart';
import 'JoinDrummButton.dart';
import 'LikeBtn.dart';
import 'ShareWidget.dart';
import 'SoundPlayWidget.dart';
import 'SwipeBackButton.dart';
import 'band_details_page.dart';
import 'custom/DrummBottomDialog.dart';
import 'custom/TutorialBox.dart';
import 'custom/ai_summary.dart';
import 'custom/bottom_sheet.dart';
import 'custom/create_drumm_widget.dart';
import 'custom/helper/AudioChannelWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model/ZoomPicture.dart';
import 'model/article_band.dart';
import 'model/home_item.dart';

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
  List<ArticleBand> articles = [];
  PageController _pageController = PageController();
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

  bool fromSearch = false;

  List<Jam> openDrumms = [];

  List<DrummCard> openDrummCards =
      []; //Colors.white.withOpacity(0.1); // Number of documents to fetch per page

  // Choose from any of these available methods

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool refreshList = true;

  double questionHeight=90;

  List<Color> backgroundColor = JOIN_COLOR;

  bool showCurrentDrummWidget = false; // Set your desired refresh interval here
  Jam currentJam = Jam();

  bool openDrumm = false;

  ArticleBand? articleOnTop = ArticleBand();

  double borderCurve = 18;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
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
                            color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          )
                        ),
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
                              article: articleOnTop?.article??Article(),
                              backgroundColor:COLOR_BACKGROUND,
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
                                border: Border.all(color: Colors.grey.shade900,width: 2.5)
                              ),
                              child: ArticleDrummButton(
                                iconSize: 44,
                                  articleOnScreen: articleOnTop?.article??Article()),
                            ),
                            if(!showCurrentDrummWidget)  JoinDrummButton(btnPadding: 12,height: 38,
                              onTap: (){
                                drumJoinDialog();
                              },),
                            if(showCurrentDrummWidget) GestureDetector(
                              onTap: (){
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
                                          bottom:
                                          MediaQuery.of(context).viewInsets.bottom),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
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
                                  border: Border.all(color: Colors.white,width: 2.5),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(2.5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(56),
                                        child: CachedNetworkImage(
                                          imageUrl: currentJam.imageUrl ?? "",
                                          fit: BoxFit.cover,
                                          height: 56,
                                          width: 56,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(42),),
                                                child: Container(
                                                  padding:  const EdgeInsets.all(8),
                                                  margin: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(42),
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
                                        borderRadius: BorderRadius.circular(42),),
                                      child: Container(
                                        padding:  const EdgeInsets.all(8),
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(42),
                                          color: Colors.transparent,
                                          //gradient: LinearGradient(colors: JOIN_COLOR),
                                        ),
                                        child: Image.asset(
                                          'images/audio-waves.png',
                                          height: iconHeight-12,
                                          color: Colors.white.withOpacity(0.35),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            LikeBtn(
                                article: Article()),
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(44),
                                  border: Border.all(color: Colors.grey.shade900,width: 2.5)
                              ),
                              child: Center(
                                child: ShareWidget(
                                  article: articleOnTop?.article??Article(),
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
                if (fromSearch)
                  SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
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
                              color: Colors.white
                                  .withOpacity(0.1), //.withOpacity(0.8),
                              //border: Border.all(color: Colors.grey.shade900.withOpacity(0.85),width: 2.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              articleOnTop?.band?.name ?? "",
                              style: const TextStyle(
                                fontSize: 12,
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
        ],
      ),
    );
  }

  void preloadNextPageImage(int nextPageIndex) async {
    if (_preloadedImages.length <= nextPageIndex) {
      final nextPageImageUrl = articles?.elementAt(nextPageIndex)?.article?.imageUrl;
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

  // Widget getArticles() {
  //   return StreamBuilder<List<Article>>(
  //     stream: _articlesController.stream,
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         // return Center(
  //         //   child: const SizedBox(
  //         //     child: Text("No Articles present"),
  //         //   ),
  //         // );
  //
  //         return const SkeletonFeed();
  //       } else {
  //         if (!loaded) return const SkeletonFeed();
  //         List<Article>? artcls = snapshot.data;
  //         artcls = RemoveDuplicate.removeDuplicateArticles(artcls!);
  //         articles = artcls;
  //
  //         // print("Size of the articles ${artcls.length}");
  //
  //         return ClipRRect(
  //           borderRadius: BorderRadius.circular(0),
  //           child: Stack(
  //             children: [
  //               RefreshIndicator(
  //                 onRefresh: _refreshData,
  //                 triggerMode: RefreshIndicatorTriggerMode.anywhere,
  //                 child: PageView.builder(
  //                   controller: _pageController,
  //                   onPageChanged: (value) {
  //                     currentVisiblePageIndex = value;
  //                     print(
  //                         "Page Changed/////////////////////// ${artcls?.elementAt(value).articleId}");
  //                     // if (autoJoinDrumms && !widget.userConnected) {
  //                     //   ConnectToChannel.joinLiveDrumm(
  //                     //       artcls?.elementAt(value) ?? Article(), true);
  //                     // }
  //                     // setState(() {
  //                     //   setColor =
  //                     //       RandomColorBackground.generateRandomVibrantColor();
  //                     // });
  //                     if (value == articles.length - 1) {
  //                       getArticlesData(false);
  //                     }
  //                     //Prefetch the next page image
  //                     if (value != articles.length - 1) {
  //                       preloadNextPageImage(value + 1);
  //                     }
  //                   },
  //                   itemCount: artcls?.length,
  //                   scrollDirection: Axis.vertical,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     if (!articleIDs
  //                         .contains(artcls?.elementAt(index).articleId)) {
  //                       articleIDs.add(artcls?.elementAt(index).articleId);
  //                       checkIfUserLiked(index);
  //                     }
  //                     //
  //
  //                     //  print("${artcls?.elementAt(0).publishedAt}");
  //                     if (artcls?.elementAt(index).imageUrl == null) {
  //                       fetchMissingImageUrls(artcls!.elementAt(index), index);
  //                       imageSet.add(artcls?.elementAt(index).articleId ?? "");
  //                       // print("Contains article ${artcls?.elementAt(index).articleId} ${imageSet.contains(artcls?.elementAt(index).articleId)}");
  //                     }
  //
  //                     //titleList![0] ?? "";
  //
  //                     return Stack(
  //                       children: [
  //                         Positioned.fill(
  //                           child: CachedNetworkImage(
  //                             fadeInDuration: const Duration(milliseconds: 0),
  //                             fit: BoxFit.cover,
  //                             alignment: Alignment.center,
  //                             width: double.infinity,
  //                             height: double.infinity,
  //                             imageUrl: artcls?.elementAt(index).imageUrl ?? "",
  //                             errorWidget: (context, url, error) {
  //                               //     Image.asset(
  //                               //   "images/logo_background_white.png",
  //                               //   color: Colors.grey.shade900
  //                               //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
  //                               //   width: 35,
  //                               //   height: 35,
  //                               // ),
  //
  //                               return Container(
  //                                 color: Colors.transparent,
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                         Container(
  //                           height: double.maxFinite,
  //                           width: double.maxFinite,
  //                         ).frosted(
  //                             blur: 9,
  //                             frostColor: Colors.black), //COLOR_PRIMARY_DARK),
  //                         Positioned.fill(
  //                           child: CachedNetworkImage(
  //                             fadeInDuration: const Duration(milliseconds: 0),
  //                             fit: (isContainerVisible)
  //                                 ? BoxFit.cover
  //                                 : BoxFit.fitWidth,
  //                             alignment: Alignment.center,
  //                             width: double.infinity,
  //                             height: double.infinity,
  //                             imageUrl: artcls?.elementAt(index).imageUrl ?? "",
  //                             progressIndicatorBuilder:
  //                                 (context, url, downloadProgress) {
  //                               return const LinearProgressIndicator(
  //                                 backgroundColor: Colors.black,
  //                                 color: Colors.black,
  //                                 // value: (downloadProgress.progress!=0)? downloadProgress.progress: 0,
  //                               );
  //                             },
  //                             errorWidget: (context, url, error) {
  //                               //     Image.asset(
  //                               //   "images/logo_background_white.png",
  //                               //   color: Colors.grey.shade900
  //                               //       .withOpacity(0.5), //(COLOR_PRIMARY_VAL),
  //                               //   width: 35,
  //                               //   height: 35,
  //                               // ),
  //
  //                               return Container(
  //                                 color: Colors.transparent,
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                         if (isContainerVisible && false)
  //                           Container(
  //                             height: double.maxFinite,
  //                             width: double.maxFinite,
  //                             decoration: BoxDecoration(
  //                                 gradient: LinearGradient(
  //                                     begin: Alignment.topCenter,
  //                                     end: Alignment.bottomCenter,
  //                                     colors: [
  //                                   Colors.black,
  //                                   Colors.black.withOpacity(0.5),
  //                                   Colors.transparent
  //                                 ])),
  //                           ),
  //                         GestureDetector(
  //                           onTap: () {
  //                             setState(() {
  //                               isContainerVisible = false;
  //                               print("Tapped images!!!!!!!!");
  //                             });
  //                           },
  //                           child: Container(
  //                             alignment: Alignment.bottomCenter,
  //                             padding: const EdgeInsets.only(
  //                                 left: 0, top: 100, right: 76, bottom: 44),
  //                             decoration: BoxDecoration(
  //                               gradient: LinearGradient(
  //                                 colors: [
  //                                   Colors.transparent,
  //                                   Colors.transparent,
  //                                   Colors.black.withOpacity(0.2),
  //                                   Colors.black.withOpacity(0.6),
  //                                   Colors.black.withOpacity(
  //                                       0.85), //.withOpacity(0.95),
  //                                 ],
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                               ),
  //                             ),
  //                             child: GestureDetector(
  //                               onTap: () {
  //                                 Vibrate.feedback(FeedbackType.light);
  //                                 openArticlePage(
  //                                     artcls?.elementAt(index), index);
  //                               },
  //                               child: Row(
  //                                 children: [
  //                                   Container(
  //                                     height: 120,
  //                                     padding: const EdgeInsets.only(right: 0),
  //                                     child: FadeInContainer(
  //                                       child: Container(
  //                                         height: double.infinity,
  //                                         width: 3,
  //                                         decoration: const BoxDecoration(
  //                                           color: Colors.white,
  //                                           borderRadius: BorderRadius.only(
  //                                               topRight: Radius.circular(0),
  //                                               bottomRight:
  //                                                   Radius.circular(0)),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Container(
  //                                       height: 150,
  //                                       padding: const EdgeInsets.all(16),
  //                                       decoration: const BoxDecoration(
  //                                         //  color: Colors.black.withOpacity(0.20),
  //                                         borderRadius: BorderRadius.only(
  //                                             topRight: Radius.circular(4),
  //                                             bottomRight: Radius.circular(4)),
  //                                       ),
  //                                       child: Column(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           Expanded(
  //                                             child: FadeInContainer(
  //                                               child: AutoSizeText(
  //                                                 artcls
  //                                                         ?.elementAt(index)
  //                                                         .title ??
  //                                                     "",
  //                                                 textAlign: TextAlign.start,
  //                                                 style: const TextStyle(
  //                                                   color: Colors.white,
  //                                                   fontFamily: APP_FONT_MEDIUM,
  //                                                   //fontWeight: FontWeight.bold,
  //                                                   fontSize: 42,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           const SizedBox(
  //                                             height: 6,
  //                                           ),
  //                                           Text(
  //                                             "Tap to view",
  //                                             textAlign: TextAlign.left,
  //                                             style: TextStyle(
  //                                               color: Colors.grey.shade700,
  //                                               fontFamily: APP_FONT_MEDIUM,
  //                                               fontSize: 12,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ).frosted(
  //                                       blur: 8,
  //                                       borderRadius: const BorderRadius.only(
  //                                           topRight: Radius.circular(4),
  //                                           bottomRight: Radius.circular(4)),
  //                                       frostColor: Colors.grey
  //                                           .shade900, //Colors.grey.shade900,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Positioned(
  //                           left: 8,
  //                           bottom: 200,
  //                           child: AnimatedTextKit(
  //                             animatedTexts: [
  //                               TyperAnimatedText(
  //                                   "${artcls?.elementAt(index).source} | ${artcls?.elementAt(index).category}",
  //                                   textStyle: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontFamily: APP_FONT_MEDIUM,
  //                                     fontSize: 14,
  //                                   ),
  //                                   speed: const Duration(milliseconds: 35)),
  //                             ],
  //                             totalRepeatCount: 1,
  //                             repeatForever: false,
  //                           ),
  //                         ),
  //                         Positioned(
  //                           left: 8,
  //                           bottom: 22,
  //                           child: InstagramDateTimeWidget(
  //                               publishedAt: artcls
  //                                       ?.elementAt(index)
  //                                       .publishedAt
  //                                       .toString() ??
  //                                   ""),
  //                         ),
  //                         Positioned(
  //                           right: 1,
  //                           bottom: 16,
  //                           child: Column(
  //                             children: [
  //                               RoundedButton(
  //                                 padding: 10,
  //                                 height: iconHeight,
  //                                 color:
  //                                     articles.elementAt(index).liked ?? false
  //                                         ? Colors.red
  //                                         : Colors.white,
  //                                 bgColor: iconBGColor,
  //                                 hoverColor: Colors.redAccent,
  //                                 onPressed: () {
  //                                   setState(() {
  //                                     if (articles.elementAt(index).liked ??
  //                                         false) {
  //                                       FirebaseDBOperations.removeLike(
  //                                           articles.elementAt(index)
  //                                               .articleId);
  //                                       setState(() {
  //                                         articles.elementAt(index).liked =
  //                                             false;
  //                                         int currentLikes = articles.elementAt(index)
  //                                                 .likes ??
  //                                             1;
  //                                         currentLikes -= 1;
  //                                         articles.elementAt(index).likes =
  //                                             currentLikes;
  //                                         _articlesController.add(articles);
  //                                       });
  //                                     } else {
  //                                       FirebaseDBOperations.updateLike(
  //                                           articles.elementAt(index)
  //                                               .articleId);
  //                                       setState(() {
  //                                         articles.elementAt(index).liked =
  //                                             true;
  //                                         int currentLikes = articles.elementAt(index)
  //                                                 .likes ??
  //                                             0;
  //                                         currentLikes += 1;
  //                                         articles.elementAt(index).likes =
  //                                             currentLikes;
  //                                         _articlesController.add(articles);
  //                                       });
  //
  //                                       Vibrate.feedback(FeedbackType.impact);
  //                                     }
  //                                   });
  //                                 },
  //                                 assetPath:
  //                                     articles.elementAt(index).liked ?? false
  //                                         ? 'images/liked.png'
  //                                         : 'images/heart.png',
  //                               ),
  //                               // if ((articles!.elementAt(index).likes ?? 0) > 0)
  //                               Column(
  //                                 children: [
  //                                   const SizedBox(
  //                                     height: 2,
  //                                   ),
  //                                   if ((articles.elementAt(index).likes ??
  //                                           0) >
  //                                       0)
  //                                     Text(
  //                                       "${articles.elementAt(index).likes}",
  //                                       style: TextStyle(fontSize: fontSize),
  //                                     ),
  //                                 ],
  //                               ),
  //                               if (false)
  //                                 SizedBox(
  //                                   height: sizedBoxedHeight,
  //                                 ),
  //                               if (false)
  //                                 RoundedButton(
  //                                   padding: 12,
  //                                   height: 55,
  //                                   color: Colors.white,
  //                                   bgColor: Colors.grey.withOpacity(0.05),
  //                                   onPressed: () {},
  //                                   assetPath: 'images/chat.png',
  //                                 ),
  //                               if (false)
  //                                 SizedBox(
  //                                   height: sizedBoxedHeight,
  //                                 ),
  //                               if (false)
  //                                 RoundedButton(
  //                                   padding: 12,
  //                                   height: iconHeight,
  //                                   color: Colors.white,
  //                                   bgColor: iconBGColor,
  //                                   onPressed: () {
  //                                     openArticlePage(
  //                                         artcls?.elementAt(index), index);
  //
  //                                     // print("Like status: ${artcls?[index].liked}");
  //                                   },
  //                                   assetPath: 'images/link.png',
  //                                 ),
  //                               // if ((articles!.elementAt(index).reads ?? 0) > 0)
  //                               if (false)
  //                                 Column(
  //                                   children: [
  //                                     const SizedBox(
  //                                       height: 2,
  //                                     ),
  //                                     Text(
  //                                       ((articles.elementAt(index).reads ??
  //                                                   0) >
  //                                               0)
  //                                           ? "${articles.elementAt(index).reads}"
  //                                           : "Reads",
  //                                       style: TextStyle(fontSize: fontSize),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               SizedBox(
  //                                 height: sizedBoxedHeight,
  //                               ),
  //                               RoundedButton(
  //                                 padding: 10,
  //                                 height: 52, //iconHeight,
  //                                 color: Colors.white,
  //                                 bgColor: iconBGColor,
  //                                 onPressed: () {
  //                                   AISummary.showBottomSheet(
  //                                       context,
  //                                       artcls!.elementAt(index) ?? Article(),
  //                                       Colors.transparent);
  //                                 },
  //                                 assetPath: 'images/sparkles.png',
  //                               ),
  //                               Column(
  //                                 children: [
  //                                   const SizedBox(
  //                                     height: 0,
  //                                   ),
  //                                   Text(
  //                                     "Summary",
  //                                     style: TextStyle(
  //                                         fontSize: fontSize,
  //                                         color: Colors.transparent),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(
  //                                 height: 4, //sizedBoxedHeight,
  //                               ),
  //                               RoundedButton(
  //                                 padding: 10,
  //                                 height: 52, //iconHeight,
  //                                 color: Colors.white,
  //                                 bgColor: Colors.grey.shade600
  //                                     .withOpacity(0.30), //Colors.white24,
  //                                 onPressed: () {
  //                                   // AISummary.showBottomSheet(
  //                                   //     context,
  //                                   //     artcls!.elementAt(index) ?? Article(),
  //                                   //     Colors.transparent);
  //                                   showModalBottomSheet(
  //                                     context: context,
  //                                     isScrollControlled: true,
  //                                     backgroundColor: Colors.grey.shade900,
  //                                     shape: const RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.vertical(
  //                                           top: Radius.circular(0.0)),
  //                                     ),
  //                                     builder: (BuildContext context) {
  //                                       return Padding(
  //                                         padding: EdgeInsets.only(
  //                                             bottom: MediaQuery.of(context)
  //                                                 .viewInsets
  //                                                 .bottom),
  //                                         child: ClipRRect(
  //                                           borderRadius:
  //                                               const BorderRadius.vertical(
  //                                                   top: Radius.circular(0.0)),
  //                                           child: ArticleJamPage(
  //                                             article:
  //                                                 articles.elementAt(index),
  //                                           ),
  //                                         ),
  //                                       );
  //                                     },
  //                                   );
  //                                 },
  //                                 assetPath: 'images/drumm_logo.png',
  //                               ),
  //                               Column(
  //                                 children: [
  //                                   const SizedBox(
  //                                     height: 6,
  //                                   ),
  //                                   Text(
  //                                     "Drumms",
  //                                     style: TextStyle(fontSize: fontSize),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(
  //                                 height: 8,
  //                               ),
  //                               // ArticleChannel(
  //                               //   articleID:
  //                               //       artcls?.elementAt(index).articleId ?? "",
  //                               //   height: iconHeight,
  //                               // ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }


  Widget getNewsArticles() {
    return StreamBuilder<List<ArticleBand>>(
      stream: _articlesController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return Center(
          //   child: const SizedBox(
          //     child: Text("No Articles present"),
          //   ),
          // );

          return const SkeletonFeed();
        } else {
          if (!loaded) return const SkeletonFeed();
          List<ArticleBand>? artcls = snapshot.data;
          //artcls = RemoveDuplicate.removeDuplicateArticles(artcls!);
          articles = artcls??[];

          // print("Size of the articles ${artcls.length}");

          return ClipRRect(
            borderRadius: BorderRadius.circular(borderCurve+2),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: backgroundColor
                  )
              ),
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) {
                        currentVisiblePageIndex = value;
                        setState(() {
                          articleOnTop = articles?.elementAt(value);
                        });

                        try{
                          FirebaseDBOperations.OggOpus_Player.pause();
                        }catch(e){

                        }

                        // print(
                        //     "Page Changed/////////////////////// ${artcls?.elementAt(value).question}");
                        // if (autoJoinDrumms && !widget.userConnected) {
                        //   ConnectToChannel.joinLiveDrumm(
                        //       artcls?.elementAt(value) ?? Article(), true);
                        // }
                        // setState(() {
                        //   setColor =
                        //       RandomColorBackground.generateRandomVibrantColor();
                        // });

                        int articleSize = articles?.length??0;

                        if (value == articleSize - 1) {
                          getArticlesData(false);
                        }
                        //Prefetch the next page image
                        if (value != articleSize - 1) {
                          preloadNextPageImage(value + 1);
                        }
                      },
                      itemCount: artcls?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        if (!articleIDs
                            .contains(artcls?.elementAt(index).article?.articleId)) {
                          articleIDs.add(artcls?.elementAt(index).article?.articleId);
                          checkIfUserLiked(index);
                        }


                        //

                        //  print("${artcls?.elementAt(0).publishedAt}");
                        if (artcls?.elementAt(index).article?.imageUrl == null) {
                          fetchMissingImageUrls(artcls!.elementAt(index).article??Article(), index);
                          imageSet.add(artcls?.elementAt(index).article?.articleId ?? "");
                          // print("Contains article ${artcls?.elementAt(index).articleId} ${imageSet.contains(artcls?.elementAt(index).articleId)}");
                        }

                        //titleList![0] ?? "";

                        return Container(
                          height:double.maxFinite,
                          width: double.maxFinite,
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  fadeInDuration: const Duration(milliseconds: 0),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: double.infinity,
                                  imageUrl: artcls?.elementAt(index).article?.imageUrl ?? "",
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
                                  blur: 75,
                                  frostOpacity: 0.25,//0.35,
                                  frostColor: Colors.grey.shade900),
                              Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 48,),
                                          SafeArea(
                                            bottom: false,
                                            child: FadeInContainer(
                                              child: AutoSizeText(
                                                unescape.convert(artcls?.elementAt(index).article?.title ?? ""),
                                                textAlign: TextAlign.start,
                                                maxLines: 5,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: APP_FONT_MEDIUM,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(top: 8,bottom: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          artcls?.elementAt(index).article?.source ?? "",
                                                          style: TextStyle(
                                                            color:
                                                            Colors.white.withOpacity(0.8),
                                                            fontSize: 13,
                                                            fontFamily: APP_FONT_MEDIUM,
                                                          )),
                                                      const Text(" • "),
                                                      InstagramDateTimeWidget(
                                                          publishedAt: artcls
                                                              ?.elementAt(index).article?.publishedAt.toString() ??
                                                              ""),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1,
                                                        animation2) =>
                                                        ZoomPicture(
                                                            url: artcls?.elementAt(index).article?.imageUrl ??
                                                                "https://placekitten.com/640/360"),
                                                    transitionDuration:
                                                    const Duration(seconds: 0),
                                                    reverseTransitionDuration:
                                                    const Duration(seconds: 0),
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(borderCurve),
                                                child: CachedNetworkImage(
                                                  fadeInDuration: const Duration(milliseconds: 0),
                                                  fit: (isContainerVisible)
                                                      ? BoxFit.cover
                                                      : BoxFit.cover,
                                                  alignment: Alignment.center,
                                                  width: double.maxFinite,
                                                  height: double.maxFinite,
                                                  imageUrl:
                                                  artcls?.elementAt(index).article?.imageUrl ?? "",
                                                  progressIndicatorBuilder:
                                                      (context, url, downloadProgress) {
                                                    return  ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Container(
                                                        color: Colors.grey.shade900.withOpacity(0.25),
                                                        height: 200,
                                                        padding: const EdgeInsets.all(48),
                                                      ),
                                                    );
                                                  },
                                                  errorWidget: (context, url, error) {


                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Container(
                                                        color: Colors.grey.shade900.withOpacity(0.25),
                                                        height: 200,
                                                        padding: const EdgeInsets.all(48),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          if(true)GestureDetector(
                                            onTap: (){
                                              openArticlePage(artcls?.elementAt(index).article,index);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
                                              margin: const EdgeInsets.symmetric(vertical: 12),
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(borderCurve),
                                                color: Colors.white.withOpacity(0.05),
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width:8,),
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    child: Image.asset(
                                                        'images/link.png',
                                                        height: 22,
                                                        color: Colors.white,
                                                        fit: BoxFit.contain),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Flexible(
                                                    child: Text(
                                                      (artcls?.elementAt(index).article?.source?.toLowerCase() ==
                                                          'youtube')
                                                          ? artcls?.elementAt(index).article?.title ?? "Read Article"
                                                          : (artcls?.elementAt(index).article?.description != null)
                                                          ? artcls?.elementAt(index).article?.description ?? "Read Article"
                                                          : (artcls?.elementAt(index).article?.content != null)
                                                          ? artcls?.elementAt(index).article?.content ?? "Read Article"
                                                          : "Read Article",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontFamily: APP_FONT_LIGHT,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      AISummary.showBottomSheet(
                                          context,
                                          artcls!.elementAt(index).article ?? Article(),
                                          Colors.transparent);
                                    },
                                    child: Container(
                                      width: double.maxFinite,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(borderCurve),
                                        //color: Colors.transparent,
                                        // borderRadius: BorderRadius.only(
                                        //   topLeft: Radius.circular(CURVE),
                                        //   topRight: Radius.circular(CURVE),
                                        // ),
                                        //gradient: LinearGradient(colors: JOIN_COLOR),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(width:6,),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(
                                                'images/sparkles.png',
                                                height: 24,
                                                color: Colors.white,
                                                fit: BoxFit.contain),
                                          ),
                                          const SizedBox(width: 6,),
                                          Expanded(
                                            child: Container(
                                              // height: questionHeight,
                                              alignment: Alignment.centerLeft,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 4),
                                              child: const Text(
                                                "Summarize the article" ??
                                                    "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: APP_FONT_BOLD,
                                                  //fontWeight: FontWeight.w400
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (artcls?.elementAt(index).article?.question != null)
                                    GestureDetector(
                                      onTap: (){
                                        drumJoinDialog();
                                      },
                                      child: Container(
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          //color: Colors.blue,//s.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(borderCurve),
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
                                            const SizedBox(width:6,),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(
                                                'images/audio-waves.png',
                                                height: 24,
                                                color: Colors.white,
                                                fit: BoxFit.contain),
                                          ),
                                            const SizedBox(width: 6,),
                                            Expanded(
                                              child: Container(
                                                // height: questionHeight,
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 4),
                                                child: Text(
                                                  unescape.convert("\"${artcls?.elementAt(index).article?.question ?? ""}\"" ??
                                                      ""),
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: APP_FONT_BOLD,
                                                      //fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 4,),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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

        List<ArticleBand> newArticlesBands = [];
        bandList = await FirebaseDBOperations.getBandByUser();

        for (Article article in newArticles) {
          for (Band band in bandList) {
            List hooks = band.hooks ?? [];
            if (hooks.contains(article.category)) {
              ArticleBand articleBand = ArticleBand(article: article, band: band);
              newArticlesBands.add(articleBand);
              break;
            }
          }
        }

        List<ArticleBand> updatedArticles = [];

        if (refresh) {
          updatedArticles = newArticlesBands + articles;

          setState(() {
            articleOnTop = updatedArticles.elementAt(0);
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
            articleOnTop = updatedArticles.elementAt(0);
          });
          _articlesController.add(updatedArticles);
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
    getBandDrumms();
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
    ConnectionListener.onConnectionChangedinVerticalHomeFeed = (connected, jam, open) {
      // Handle the channelID change here
      // print("onConnectionChanged called in Launcher");
      if(mounted)
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

  void getPalette(String url) async{
    if(url.length<1) {
      //setState(() {
        backgroundColor = [Colors.black, COLOR_PRIMARY_DARK];
      //});
      return;
    }
    try {
      PaletteGenerator paletteGenerator = await PaletteGenerator
          .fromImageProvider(
        NetworkImage(url),
        maximumColorCount: 3,
      ).catchError((e) {}
      );
      List<Color> extractedColors = [];
      extractedColors.add(

          (paletteGenerator.darkMutedColor!=null)? paletteGenerator.darkMutedColor?.color??COLOR_PRIMARY_DARK:
          (paletteGenerator.darkVibrantColor!=null)? paletteGenerator.darkVibrantColor?.color??COLOR_PRIMARY_DARK:
          (paletteGenerator.lightVibrantColor!=null)? paletteGenerator.lightVibrantColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          (paletteGenerator.lightMutedColor!=null)? paletteGenerator.lightMutedColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          (paletteGenerator.dominantColor!=null)? paletteGenerator.dominantColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          Colors.grey.shade900);
      extractedColors.add(
          (paletteGenerator.dominantColor!=null)? paletteGenerator.dominantColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          (paletteGenerator.lightMutedColor!=null)? paletteGenerator.lightMutedColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          (paletteGenerator.lightVibrantColor!=null)? paletteGenerator.lightVibrantColor?.color.withOpacity(0.5)??COLOR_PRIMARY_DARK:
          (paletteGenerator.darkVibrantColor!=null)? paletteGenerator.darkVibrantColor?.color??COLOR_PRIMARY_DARK:
          (paletteGenerator.darkMutedColor!=null)? paletteGenerator.darkMutedColor?.color??COLOR_PRIMARY_DARK:
          Colors.grey.shade900);
      //extractedColors.add(paletteGenerator.darkMutedColor?.color??Colors.grey.shade900);
      //paletteGenerator.
      List<Color> opacityColor = paletteGenerator.colors.toList();
      //extractedColors.add(COLOR_PRIMARY_DARK);


      for(Color color in opacityColor){
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
    }catch(e){
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
    refreshFeed();
    widget.scrollController.addListener(_handleScroll);
    // _pageController.addListener(() {
    //   int initialPage = _pageController.initialPage;
    // });
    listenToJamState();
    getBandDrumms();
    getOpenDrumms();
    getCurrentDrummer();
  }

  void getBandsList() async{
    bandList = await FirebaseDBOperations.getBandByUser();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   // Your code to react to app coming to the foreground in the HomeFeed widget
    //   _checkAndScheduleRefresh();
    // } else {
    //   refreshList = true;
    //   _stopRefreshTimer(); // Stop the timer when the app goes to the background
    // }
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

  void refreshFeed() async{
    if (widget.preloadList == null) {
      getArticlesData(true);
      // AnimatedSnackBar.material(
      //     'Refreshed List',
      //     type: AnimatedSnackBarType.success,
      //     mobileSnackBarPosition: MobileSnackBarPosition.top
      // ).show(context);
    } else {
      List<Article> fetchedList = widget.preloadList ?? [];
      List<ArticleBand> fetchedArticleBand = [];
      bandList = await FirebaseDBOperations.getBandByUser();
      for (Article article in fetchedList) {
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
        articleOnTop = fetchedArticleBand.elementAt(0);
        fromSearch = true;
        isContainerVisible = false;
        _articlesController.add(fetchedArticleBand ?? []);
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

    FirebaseDBOperations.hasLiked(articles.elementAt(index).article?.articleId)
        .then((value) {
      setState(() {
        articles.elementAt(index).article?.liked = value;
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
    articles.elementAt(index).article = returnData!;
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

  void openJamRoom(Jam jam, bool open) {
    FirebaseDBOperations.sendNotificationToTopic(jam, false, open);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
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
              open: open,
            ),
          ),
        );
      },
    );
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
        // return TutorialBox(
        //   boxType: BOX_TYPE_CONFIRM,
        //   sharedPreferenceKey: CONFIRM_JOIN_SHARED_PREF,
        //   tutorialImageAsset: "images/audio-waves.png",
        //   tutorialMessage: TUTORIAL_MESSAGE_JOIN,
        //   tutorialMessageTitle: TUTORIAL_MESSAGE_JOIN_TITLE,
        //   onConfirm: (){
        //     ArticleBand? articleBand = ArticleBand();
        //     articleBand = articleOnTop;
        //     Vibrate.feedback(FeedbackType.success);
        //     joinOpenDrumm(articleBand??ArticleBand());
        //   },
        //   onCancel: (){
        //
        //   },
        // );
        return DrummBottomDialog(articleBand: articleOnTop, startDrumming: () {
          ArticleBand? articleBand = ArticleBand();
          articleBand = articleOnTop;
          Vibrate.feedback(FeedbackType.success);
          joinOpenDrumm(articleBand??ArticleBand());
        },);
      },
    );
  }
}
