import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/SettingsPage.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

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

  double badgeOffset = 2;


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
                      decoration: BoxDecoration(
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
                      "@${drummer?.username}",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontFamily: APP_FONT_BOLD,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${drummer?.jobTitle ?? ""}\n${drummer?.occupation ?? ""}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: APP_FONT_MEDIUM, color: Colors.white),
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
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM, color: Colors.white54),
                        linkColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
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
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                                fontFamily: APP_FONT_BOLD,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                   if(false) Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        width: double.maxFinite,
                        child: Text(
                          "Stats",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: APP_FONT_BOLD),
                        )),
                   if(false) SizedBox(
                      height: 8,
                    ),

                    if(pieChartList.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 1,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace:2,
                                centerSpaceRadius: 125,
                                centerSpaceColor: Colors.transparent,
                                sections: pieChartList,
                              ),
                            ),
                            if(pieChartList.isNotEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.orange,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Entertainment", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.green,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Business", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.yellow,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Science", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.indigoAccent,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Technology", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.purpleAccent,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Sports", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Politics", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.red,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("Health", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.grey,
                                            width: 10,
                                            height: 10,
                                          ),
                                          SizedBox(width: 8,),
                                          Text("General", style: TextStyle(color: Colors.white,fontSize: 12),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if(pieChartList.isNotEmpty)
                      SizedBox(
                        height: 32,
                        child: AutoSizeText(
                          textAlign: TextAlign.center,
                          "Lvl. ${magnitude}",
                          maxFontSize: 32,
                          minFontSize: 14,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: APP_FONT_BOLD),
                        ),
                      ),

                    SizedBox(
                      height: 24,
                    ),
                    if (questionCards.isNotEmpty)
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          width: double.maxFinite,
                          child: Text(
                            "Questions",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_BOLD),
                          )),
                    SizedBox(
                      height: 8,
                    ),
                    if (questionCards.isNotEmpty)
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        //height: double.maxFinite,//MediaQuery.of(context).size.height,
                        child: ListView(
                          padding: EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
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
                        child: Text(
                          "There's nothing here",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
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
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  if (drummer?.username != null&&false)
                    SafeArea(
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(8),
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
                          padding: EdgeInsets.all(8),
                          child: Icon(
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

    getPieChartList();
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

  List<PieChartSectionData> showingSections(Stats drummerState) {
    return List.generate(8, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = 14.0;//isTouched ? 20.0 : 16.0;
      final radius = 4.0;//isTouched ? 110.0 : 100.0;
      final widgetSize = 42.0;//isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 1:
          return PieChartSectionData(
            color: Colors.green,
            value: drummerState.business?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/money-bag.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 0:
          return PieChartSectionData(
            color: Colors.orange,
            value: drummerState.entertainment?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/movie.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 2:
          return PieChartSectionData(
            color: Colors.yellow,
            value: drummerState.science?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/atom.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 4:
          return PieChartSectionData(
            color: Colors.purpleAccent,
            value: drummerState.sports?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/football.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 6:
          return PieChartSectionData(
            color: Colors.red,
            value: drummerState.health?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/healthcare.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 5:
          return PieChartSectionData(
            color: Colors.white,
            value: drummerState.politics?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/goverment.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 3:
          return PieChartSectionData(
            color: Colors.indigoAccent,
            value: drummerState.technology?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/cpu.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        case 7:
          return PieChartSectionData(
            color: Colors.grey,
            value: drummerState.general?.toDouble()??0.1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            // badgeWidget: _Badge(
            //   'images/world.png',
            //   size: widgetSize,
            //   borderColor: Colors.black,
            // ),
            // badgePositionPercentageOffset: badgeOffset,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }

  void getPieChartList() async{
    Stats drummerState = await FirebaseDBOperations.getDrummerStats(FirebaseAuth.instance.currentUser?.uid??"");
    if(drummerState==null){
      print("Drummer Stats is null");
    }

    totalState = drummerState.general??0;
    totalState +=  drummerState.science??0;
    totalState +=  drummerState.sports??0;
    totalState +=  drummerState.technology??0;
    totalState +=  drummerState.health??0;
    totalState +=  drummerState.politics??0;
    totalState +=  drummerState.entertainment??0;
    totalState +=  drummerState.business??0;



    List<PieChartSectionData> fetchPieChartList = showingSections(drummerState);
    bool containsValue = false;

    if(totalState >0) {
      containsValue = true;
      print("Contain value: $totalState");
    }else{
      print("Does not contain value;");
    }

    if(containsValue) {
      setState(() {
        pieChartList = fetchPieChartList;
        magnitude = totalState;
      });
    }

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
      decoration: BoxDecoration(
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

