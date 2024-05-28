import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/SettingsPage.dart';
import 'package:drumm_app/StatsDescriptionBox.dart';
import 'package:drumm_app/model/StateItem.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/edit_profile.dart';
import 'package:drumm_app/main.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/image_uploader.dart';
import 'model/QuestionCard.dart';
import 'model/Stats.dart';
import 'model/question.dart';

class UserProfilePage extends StatefulWidget {
  Drummer? drummer;
  bool? fromSearch;
  UserProfilePage({Key? key, this.drummer, this.fromSearch}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin<UserProfilePage> {
  String profileImageUrl = "";
  Drummer? drummer = Drummer();

  String? currentID = "";
  int touchedIndex = -1;

  bool followed = false;
  bool fromSearch = false;
  List<Question> questions = [];
  List<QuestionCard> questionCards = [];
  List<PieChartSectionData> pieChartList = [];

  int totalState = 0;
  int magnitude = 0;
  int drummScore = 0;
  int level = 1;
  int mod = 0;
  String topVibe = "";

  double badgeOffset = 2;

  ValueNotifier<double> _valueNotifier = ValueNotifier(1);
  List<ChartLayer> chartLayer = [];
  List<ChartLayer> largeChartLayer = [];

  List<StatsItem> stateList = [];

  @override
  Widget build(BuildContext context) {
    print(
        "User background image ${modifyImageUrl(drummer?.imageUrl ?? "", "100x100")}");
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: 1.0,
      child: Scaffold(
        backgroundColor: COLOR_BACKGROUND,
        body: Stack(
          children: [
            if (false)
              Hero(
                tag: drummer?.imageUrl ?? "",
                child: CachedNetworkImage(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  imageUrl: modifyImageUrl(drummer?.imageUrl ?? "",
                      "100x100"), //widget.drummer?.imageUrl ?? "",
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: COLOR_PRIMARY_DARK),
                  errorWidget: (context, url, error) =>
                      Container(color: COLOR_PRIMARY_DARK),
                ),
              ),
            if (false)
              Container(
                alignment: Alignment.topCenter,
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        COLOR_BACKGROUND,
                        COLOR_BACKGROUND
                      ]),
                ),
              ).frosted(blur: 24, frostColor: COLOR_BACKGROUND),
            if (false)
              IgnorePointer(
                child: Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 100,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                              ])),
                    ),
                  ),
                ),
              ),
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                //physics: AlwaysScrollableScrollPhysics(),

                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(CURVE),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 150,
                          ),
                          if (drummer?.imageUrl != null)
                            Center(
                              child: SizedBox(
                                width: 175,
                                height: 175,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: modifyImageUrl(
                                        drummer?.imageUrl ?? "", "300x300"),
                                    placeholder: (context, url) {
                                      return Container();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 4,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "@${drummer?.username}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white30,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            drummer?.name ?? "",
                            style: const TextStyle(
                                fontSize: 24,
                                fontFamily: APP_FONT_BOLD,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 0,
                          ),
                          Text(
                            "${drummer?.jobTitle ?? ""}\n${drummer?.occupation ?? ""}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: APP_FONT_MEDIUM,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ExpandableText(
                              drummer?.bio ?? "",
                              expandText: 'show more',
                              collapseText: 'show less',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: APP_FONT_MEDIUM,
                                  color: Colors.white54),
                              linkColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  GestureDetector(
                                    onTap: (){
                                      Vibrate.feedback(FeedbackType.light);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatsDescriptionBox(
                                            boxType: BOX_TYPE_ALERT,
                                            autoUpdate: true,
                                            chartLayer: [],
                                            stateList:[],
                                            tutorialImageAsset: "images/team_active.png",
                                            tutorialMessageTitle: totalState.toString(),
                                            type: "Drumm Score",
                                            tutorialMessage: DRUMM_SCORE_DESCRIPTION,
                                            //TUTORIAL_MESSAGE_BANDS_TITLE,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      // margin: EdgeInsets.all(12),
                                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color:
                                          Colors.grey.shade800.withOpacity(0.35),
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 24,
                                            width: 24,
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24),
                                              color: Colors.grey.shade800
                                                  .withOpacity(0.25),
                                            ),
                                            child: Image.asset(
                                              "images/drumm_logo.png",
                                              height: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "${totalState}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Vibrate.feedback(FeedbackType.light);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatsDescriptionBox(
                                            boxType: BOX_TYPE_ALERT,
                                            autoUpdate: true,
                                            chartLayer: [],
                                            stateList:[],
                                            tutorialImageAsset: "images/team_active.png",
                                            tutorialMessageTitle: level.toString(),
                                            type: "Level",
                                            magnitude: magnitude,
                                            checkLevel: true,
                                            valueNotifier:_valueNotifier,
                                            tutorialMessage: DRUMM_LEVEL_DESCRIPTION,
                                            //TUTORIAL_MESSAGE_BANDS_TITLE,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      //margin: EdgeInsets.symmetric(horizontal: 16),
                                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                      decoration: BoxDecoration(
                                          color:
                                          Colors.grey.shade900.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(32),
                                          border: Border.all(
                                            color:
                                            Colors.grey.shade800.withOpacity(0.35),
                                            width: 2,
                                          )),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 24,
                                            width: 24,
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24),
                                              color: Colors.grey.shade800
                                                  .withOpacity(0.25),
                                            ),
                                            child:
                                            DashedCircularProgressBar.aspectRatio(
                                              aspectRatio: 1, // width ÷ height
                                              valueNotifier: _valueNotifier,
                                              progress: magnitude.toDouble(),
                                              // startAngle: 225,
                                              // sweepAngle: 270,
                                              foregroundColor: Colors.lightBlueAccent,
                                              backgroundColor: Colors.grey.shade800
                                                  .withOpacity(0.25),
                                              foregroundStrokeWidth: 4,
                                              backgroundStrokeWidth: 4,
                                              animation: true,
                                              seekSize: 0,
                                              seekColor: Colors.grey.shade900,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            '${level}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  if (largeChartLayer.isNotEmpty)
                                  GestureDetector(
                                    onTap: (){
                                      Vibrate.feedback(FeedbackType.light);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatsDescriptionBox(
                                            boxType: BOX_TYPE_ALERT,
                                            autoUpdate: true,
                                            chartLayer: largeChartLayer,
                                            stateList:stateList,
                                            tutorialImageAsset: "images/team_active.png",
                                            tutorialMessageTitle: topVibe,
                                            type: "Top Vibe",
                                            tutorialMessage: TOP_VIBE_DESCRIPTION,
                                           //TUTORIAL_MESSAGE_BANDS_TITLE,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      // margin: EdgeInsets.all(12),
                                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color:
                                          Colors.grey.shade800.withOpacity(0.35),
                                            width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 24,
                                            width: 24,
                                            child: Chart(
                                              layers: chartLayer,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "${topVibe}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
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
                          const SizedBox(
                            height: 8,
                          ),
                          if (drummer?.uid == currentID)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                              drummer: drummer,
                                            )));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                      fontFamily: APP_FONT_BOLD,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 12,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    if (questionCards.isNotEmpty)
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          width: double.maxFinite,
                          child: const Text(
                            "Questions",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_BOLD),
                          )),
                    const SizedBox(
                      height: 8,
                    ),
                    if (questionCards.isNotEmpty)
                      Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        //height: double.maxFinite,//MediaQuery.of(context).size.height,
                        child: ListView(
                          padding: const EdgeInsets.all(0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: questionCards,
                        ),
                      ),
                    if (questionCards.isEmpty && false)
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: 100,
                        width: double.maxFinite,
                        child: const Text(
                          "There's nothing here",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (fromSearch)
                    SafeArea(
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  if (drummer?.username != null && false)
                    SafeArea(
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "@${drummer?.username}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: APP_FONT_MEDIUM,
                              fontSize: 20,
                            ),
                          )),
                    ),
                  if (drummer?.uid == currentID)
                    SafeArea(
                        child: GestureDetector(
                      onTap: () {
                        openSettingsPage();
                      },
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 32,
                          )),
                    )),
                ],
              ),
            ),

            ///The below logic will be enable when the feature, ask this person is implement
            if (false)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        alignment: Alignment.center,
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Image.asset(
                          "images/audio-waves.png",
                          color: Colors.white,
                          height: 32,
                          width: 32,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<ArticleImageCard> articleCards = [];
  List<Article> articles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
    if (widget.fromSearch != null) {
      setState(() {
        fromSearch = widget.fromSearch!;
      });
    }
  }

  Future<bool> getDrummerQuestion(String uid) async {
    questionCards.clear();
    //getUserBands();
    questions = await FirebaseDBOperations.getQuestionsAskedByUserId(uid);
    List<QuestionCard> fetchedQuestionCards = questions.map((question) {
      return QuestionCard(
        question: question,
        deleteItem: true,
        deleteCallback: (question) {
          updateList(question);
        },
        cardWidth: double.maxFinite,
      );
    }).toList();

    print("Questions list ${fetchedQuestionCards.length}");

    setState(() {
      questionCards = fetchedQuestionCards;
    });
    return true;
  }

  void initialise() {
    String? uid = "";
    if (widget.drummer == null) {
      uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      FirebaseDBOperations.getDrummer(uid).then((value) {
        setState(() {
          currentID = uid;
          drummer = value;
        });
      });
    } else {
      setState(() {
        currentID = FirebaseAuth.instance.currentUser?.uid ?? "";
        drummer = widget.drummer;
      });

      uid = widget.drummer?.uid;
    }
    //getArticles(uid);
    checkIfUserisFollowing();
    String currId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid == currId) getDrummerQuestion(uid ?? "");

    //getPieChartList(uid ?? "");
    getLayers(uid ?? "");
  }

  Future<void> _refreshData() async {
    initialise();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void followUser() async {
    bool status = await FirebaseDBOperations.followUser(widget.drummer?.uid);
    setState(() {
      if (status) followed = true;
    });
  }

  void unfollow() async {
    bool status = await FirebaseDBOperations.unfollowUser(widget.drummer?.uid);
    setState(() {
      if (status) followed = false;
    });
  }

  void checkIfUserisFollowing() async {
    bool status = await FirebaseDBOperations.isFollowing(widget.drummer?.uid);
    setState(() {
      followed = status;
    });
  }

  void openSettingsPage() {
    Navigator.push(
        context, SwipeablePageRoute(builder: (context) => SettingsPage()));
  }

  void updateList(Question? question) {
    getDrummerQuestion(FirebaseAuth.instance.currentUser!.uid ?? "");
  }

  void getLayers(String uid) async {
    Stats drummerState = await FirebaseDBOperations.getDrummerStats(uid);
    if (drummerState == null) {
      print("Drummer Stats is null");
    }
    bool containsValue = false;

    String setVibe = "Top Vibe";

    int max = 0;
    int getScore = drummerState.general??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "General";
    }
    getScore = drummerState.science??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Science";
    }

    getScore = drummerState.sports??0;
    if(max<getScore!) {
      max = getScore;
      setVibe = "Sports";
    }

    getScore = drummerState.technology??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Technology";
    }

    getScore = drummerState.health??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Health";
    }

    getScore = drummerState.politics??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Politics";
    }

    getScore = drummerState.entertainment??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Entertainment";
    }

    getScore = drummerState.business??0;
    if(max<getScore) {
      max = getScore;
      setVibe = "Business";
    }

    print("Top vibe: ${setVibe}");

    totalState = drummerState.general ?? 0;
    totalState += drummerState.science ?? 0;
    totalState += drummerState.sports ?? 0;
    totalState += drummerState.technology ?? 0;
    totalState += drummerState.health ?? 0;
    totalState += drummerState.politics ?? 0;
    totalState += drummerState.entertainment ?? 0;
    totalState += drummerState.business ?? 0;

    List<StatsItem> stateItemList = [];
    stateItemList.add(StatsItem(
      drummerState.general ?? 0,
      "General",
      Colors.tealAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.science ?? 0,
      "Science",
      Colors.lightGreenAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.sports ?? 0,
      "Sports",
      Colors.lightBlueAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.technology ?? 0,
      "Technology",
      Colors.indigoAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.health ?? 0,
      "Health",
      Colors.redAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.politics ?? 0,
      "Politics",
      Colors.pinkAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.entertainment ?? 0,
      "Entertainment",
      Colors.purpleAccent,
    ));
    stateItemList.add(StatsItem(
      drummerState.business ?? 0,
      "Business",
      Colors.orangeAccent,
    ));

    List<ChartLayer> finalLayer = [
      getGroupPieLayer(stateItemList,false),
    ];

    List<ChartLayer> largeFinalLayer = [
      getGroupPieLayer(stateItemList,true),
    ];


    if (totalState > 0) {
      containsValue = true;
      print("Contain value: $totalState");
    } else {
      print("Does not contain value;");
    }
    if (containsValue) {
      setState(() {
        topVibe = setVibe;
        stateList = stateItemList;
        chartLayer = finalLayer;
        largeChartLayer = largeFinalLayer;
        drummScore = totalState;
        mod = totalState ~/ 100;
        magnitude = totalState - (mod * 100);
        level = mod + 1;
      });
    }
  }

  ChartGroupPieLayer getGroupPieLayer(List<StatsItem> stateItemList,bool large) {
    List<ChartGroupPieDataItem> chartGroupPieDataItemList = List.from(
      stateItemList.map(
        (e) => ChartGroupPieDataItem(
          amount: e.score?.toDouble() ?? 0.1,
          color: e.itemColor ?? Colors.grey,
          label: '${e.category}',
        ),
      ),
    );
    return ChartGroupPieLayer(
      items: List.generate(
        1,
        (index) => chartGroupPieDataItemList,
      ),
      settings: (large)?const ChartGroupPieSettings(
          radius: 50, thickness: 12, gapSweepAngle: 24):
      const ChartGroupPieSettings(
          radius: 24, thickness: 2.5, gapSweepAngle: 30),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        // border: Border.all(
        //   color: borderColor,
        //   width: 2,
        // ),
        boxShadow: <BoxShadow>[
          // BoxShadow(
          //   color: Colors.black.withOpacity(.5),
          //   offset: const Offset(3, 3),
          //   blurRadius: 3,
          // ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.25),
      child: Center(
        child: Image.asset(
          svgAsset,
          color: Colors.white,
        ),
      ),
    );
  }
}
