import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/live_drumms.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
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

class _NewsFeedState extends State<NewsFeed> {
  List<Article> articles = [];
  late CardSwiperController? controller;
  List<MultiSelectCard<dynamic>> mulList = [];
  String selectedCategory = "All";
  List<dynamic> mAllSelectedItems = [];
  late MultiSelectContainer multiSelectContainer;
  List<MultiSelectCard<dynamic>> bandsCards = [];
  Drummer drummer = Drummer();
  double horizontalPadding = 8;

  bool loadAnimation = false;

  String selectedBandID = "All";
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
                  GestureDetector(
                    onTap: (){
                      print("Tapped on live drumm");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LiveDrumms(),
                          ));
                    },
                    child: SizedBox(
                      height: 42,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LiveDrumms(),
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade800,
                                      Colors.grey.shade800
                                    ]
                                  )
                                ),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: Colors.grey.shade900,
                                    ),
                                    child: Icon(Icons.language,size: 36))),
                          ),
                        if(false)  SizedBox(height: 2,),
                          if(false)  Flexible(child: AutoSizeText("Live",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red),)),
                        ],
                      ),
                    ),
                  ),
                    Expanded(
                      child: Text(
                        "drumm",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'alata',
                        ),
                      ),
                    ),
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
                        width: 42,
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
                              child: CachedNetworkImage(
                                  width: 36,
                                  height: 36,
                                  imageUrl: drummer.imageUrl ?? "",
                                  fit: BoxFit.cover),
                            ),
                          ):RoundedButton(height: 30,padding: 6,assetPath: "images/user_profile_active.png",color: Colors.white, bgColor: Colors.grey.shade900, onPressed: (){})),
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
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    height: 50,
                    child: multiSelectContainer),
              SizedBox(
                height: 4,
              ),
              if (articles.length < 1 || loadAnimation)
                Expanded(
                    child: Lottie.asset('images/animation_loading.json',
                        fit: BoxFit.contain, width: double.maxFinite)),
              if (articles.length > 0)
                Expanded(
                  child: CardSwiper(
                    controller: controller,
                    cardsCount: articles.length,
                    duration: Duration(milliseconds: 300),
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
                          updateList: (article) {}, undo: () { controller?.undo(); },
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
  @override
  void dispose() {
    if(controller!=null)
      controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setOnboarded();
    FirebaseDBOperations.lastDocument = null;
    controller = CardSwiperController();
    getArticles();
    getBandsCards();
    getCurrentDrummer();
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
            color: Colors.grey.shade900,
            border: Border.all(color: Color(0xff2f2f2f)),
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
}
