import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/rounded_button.dart';
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
    with AutomaticKeepAliveClientMixin<NewsFeed>{
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
  final String LOADING_ASSET = "images/animation_loading.json";
  final String NO_FOUND_ASSET = "images/animation_nothing_found.json";

  DateTime? _lastRefreshTime;
  Timer? _refreshTimer;
  final Duration refreshInterval = const Duration(minutes: 15);

  bool loadAnimation = false;

  String selectedBandID = "All";

  bool noArticlesPresent=false;
  bool liveDrummsExist = false;

  double drummLogoSize = 25;

  var keepAlive = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 2,horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 4,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfilePage(
                                    drummer: drummer,
                                    fromSearch: true,
                                  ),
                            ));
                      },
                      child: Container(
                          width: 36,
                          height: 36,
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade800
                          ),
                          child: (drummer.imageUrl!=null)?Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(19),
                                color: Colors.black
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                  width: 36,
                                  height: 36,
                                  imageUrl: drummer.imageUrl ?? "",
                                  fit: BoxFit.cover),
                            ),
                          ):RoundedButton(height: 32,padding: 6,assetPath: "images/user_profile_active.png",color: Colors.white, bgColor: Colors.grey.shade900, onPressed: (){})),
                    ),
                    SizedBox(width: 4,),
                   if(false) SizedBox(
                      height: drummLogoSize,
                      width: drummLogoSize,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Image.asset(
                          "images/logo_icon.png",
                          color: Colors.blue,
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                   if(true) Expanded(
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
                   if(false)  Expanded(child: Container()),
                    SizedBox(
                      height: 36,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                liveDrummsExist = false;
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
                                    gradient: (liveDrummsExist) ? LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.cyan
                                        ]
                                    ) : LinearGradient(
                                        colors: [
                                          Colors.grey.shade800,
                                          Colors.grey.shade800,
                                        ]
                                    )
                                ),
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.grey.shade900,
                                    ),
                                    child: Icon(Icons.radar_rounded,size: 32))),
                          ),
                          if(false)  SizedBox(height: 2,),
                          if(false)  Flexible(child: AutoSizeText("Live",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red),)),
                        ],
                      ),
                    ),
                    SizedBox(width: 4,),
                    SizedBox(
                      height: 36,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                liveDrummsExist = false;
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
                                      child: NotificationWidget(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                child: Image.asset("images/notification.png",height: 30,fit: BoxFit.contain,color: Colors.white,)),//Icon(Icons.notifications_on_rounded,size: 32))),
                          ),
                          if(false)  SizedBox(height: 2,),
                          if(false)  Flexible(child: AutoSizeText("Live",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red),)),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
              ),
              if (bandsCards.length > 0)
                SizedBox(
                  height: 8,
                ),
              if (bandsCards.length > 0)
                Container(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
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
                        fit: StackFit.expand,
                        children: [
                          Lottie.asset(loadingAnimation,
                              fit: BoxFit.contain, width: double.maxFinite),
                          if(articles.length < 1 && loadAnimation) Center(child: Text("You're all caught up")),
                        ],
                      ),
                    )),
              if (articles.length > 0)
                Expanded(
                  child: CardSwiper(
                    controller: controller,
                    cardsCount: articles.length,
                    duration: Duration(milliseconds: 200),
                    maxAngle: 60,
                    scale: 0.85,
                    numberOfCardsDisplayed: (articles.length>1)?2:1,
                    isVerticalSwipingEnabled: false,
                    onEnd: () {
                      print("Ended swipes");
                      setState(() {
                        //loadAnimation = true;
                        articles.clear();
                        controller = CardSwiperController();
                      });

                      if (selectedBandID == "All")
                        getArticles();
                      else
                        getArticlesForBand(selectedBandID);
                    },
                    threshold: 50,
                    onSwipe: _onSwipe,
                    isLoop: false,
                    onUndo: _onUndo,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    cardBuilder: (context, index) {
                     // print("Index of element $index");
                      if (index >= 0)
                        return HomeItem(
                          article: articles.elementAt(index),
                          isContainerVisible: false,
                          openArticle: (article) {
                            openArticlePage(article, index);
                          },
                          updateList: (article) {}, undo: () {
                            // setState(() {
                            //   controller = CardSwiperController();
                            // });

                            controller?.undo(); },
                          onRefresh: () {
                            return _refreshData();
                          },
                        );
                    },
                  ),
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
    setOnboarded();
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    //controller = CardSwiperController();
    getArticles();
    getCurrentDrummer();
    checkLiveDrumms();
    // Refresh your data
    //getNews();
  }
  @override
  void dispose() {
    if(controller!=null)
      controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadingAnimation = LOADING_ASSET;
    super.initState();
    setOnboarded();
    _lastRefreshTime = DateTime.now();
    _checkAndScheduleRefresh();
    FirebaseDBOperations.lastDocument = null;
    controller = CardSwiperController();
    getArticles();
    getBandsCards();
    getCurrentDrummer();
    checkLiveDrumms();
  }


  void getBandsCards() async {
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
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  width: 28,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Image.asset(
                      "images/drumm_logo.png",
                      color: Colors.white,
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text("All")
              ],
            ),
          ),
        );
      } else
        mulList.add(
          MultiSelectCard(
            value: element,
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  width: 28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: element.url ?? "",
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
    });

    setState(() {
      bandsCards = mulList;
      multiSelectContainer = getMultiSelectWidget(context);
      print("bandsCards size ${bandsCards.length}");
    });
  }

  Future<void> checkLiveDrumms() async {
    List<Jam> fetchedDrumms =
    await FirebaseDBOperations.getDrummsFromBands();
    if(fetchedDrumms.length>0){
      setState(() {
        liveDrummsExist = true;
      });
      return;
    }
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    if(broadcastJams.length>0){
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
            padding: EdgeInsets.only(left: 1, right: 2),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
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
            color: COLOR_PRIMARY_DARK,//Colors.grey.shade900,
            border: Border.all(color: Colors.grey.shade900),//Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(18)),
        selectedDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.blue,
              Colors.cyan]),
            border: Border.all(color: Colors.blue[700]!),
            borderRadius: BorderRadius.circular(18)),
        disabledDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.blue]),
            color: Color(0xff2f2f2f),
            border: Border.all(color: Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(18)),
      ),
      items: bandsCards,
      textStyles: MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'alata',
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'alata',
        ),
      ),
      onChange: (allSelectedItems, selectedItem) {
        FirebaseDBOperations.lastDocument = null;
        controller = CardSwiperController();
        setState(() {
          //selectedCategory = selectedItem;
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

    List<Article> articleFetched =
        await FirebaseDBOperations.getArticlesByBands();
    if(articleFetched.length<1) {
      setState(() {
        noArticlesPresent = true;
        //loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });

    }
    else {
      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        loadingAnimation = LOADING_ASSET;
      });

    }
    setState(() {
      articles = articleFetched;
      print("Article length ${articles.length}");
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    cleanCache();
    if (direction == CardSwiperDirection.left) {
      Vibrate.feedback(FeedbackType.selection);
      FirebaseDBOperations.updateSeen(articles.elementAt(previousIndex).articleId);
      return true;
    }

    if (ConnectToChannel.channelID == null ||
        ConnectToChannel.channelID == "") {
      Vibrate.feedback(FeedbackType.heavy);
      joinOpenDrumm(articles.elementAt(previousIndex));
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
                  SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          joinOpenDrumm(articles.elementAt(previousIndex));

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
                        onTap: (){
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
    List<Article> fetchcedArticle =
        await FirebaseDBOperations.getArticlesByBandID(bandID);

    if(fetchcedArticle.length<1) {
      setState(() {
        noArticlesPresent = true;
       // loadingAnimation = NO_FOUND_ASSET;
        loadAnimation = true;
      });

    }
    else {
      setState(() {
        noArticlesPresent = false;
        loadAnimation = false;
        loadingAnimation = LOADING_ASSET;
      });

    }

    setState(() {
      articles = fetchcedArticle;
      print("Article length ${articles.length}");
    });
  }

  void joinOpenDrumm(Article article) {
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = article.title;
    jam.bandId = article.category;
    jam.jamId = article.articleId;
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

  void getCurrentDrummer() async{
    Drummer curDrummer = await FirebaseDBOperations.getDrummer(FirebaseAuth.instance.currentUser?.uid??"");
    setState(() {
      drummer = curDrummer;
    });
  }

  void cleanCache() async {
    await DefaultCacheManager().emptyCache();
  }

  void setOnboarded() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
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
}
