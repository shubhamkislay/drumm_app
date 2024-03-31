import 'package:auto_size_text/auto_size_text.dart';
import 'package:drumm_app/SkeletonHomeItem.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/drumm_card.dart';
import 'package:drumm_app/skeleton_band.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_band.dart';
import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/QuestionCard.dart';
import 'model/band.dart';
import 'model/jam.dart';
import 'model/live_drumm_card.dart';
import 'model/question.dart';

class CommunityQuestionsPage extends StatefulWidget {
  @override
  State<CommunityQuestionsPage> createState() => CommunityQuestionsPageState();
}

class CommunityQuestionsPageState extends State<CommunityQuestionsPage>
    with AutomaticKeepAliveClientMixin<CommunityQuestionsPage> {
  List<DrummCard> drummCards = [];
  List<DrummCard> userDrummCards = [];
  List<Band> bands = [];
  List<Jam> drumms = [];
  bool loaded = false;

  List<Question> questions = [];
  List<QuestionCard> questionCards = [];

  bool showLiveALert = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (false)
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(colors: [
                                          Colors.grey.shade900,
                                          Colors.grey.shade900
                                        ])),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(24),
                                          color: Colors.grey.shade900,
                                        ),
                                        child: const Icon(Icons.language, size: 42))),
                              const SizedBox(
                                width: 0,
                              ),
                              const AutoSizeText(
                                "Questions",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontFamily: APP_FONT_MEDIUM,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (questionCards.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: GridView.count(
                                crossAxisCount: 2, // Number of columns
                                childAspectRatio: 0.8,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: questionCards),
                          ),
                        if (questionCards.isEmpty && loaded)
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(32),
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: const Text(
                                "There are currently no questions from the community",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: APP_FONT_MEDIUM,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (loaded)
                if (false)
                  Container(
                    alignment: Alignment.bottomLeft,
                    height: 100,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black])),
                  ),
            if(false)  Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                alignment: Alignment.bottomCenter,
                child: IconLabelButton(
                  imageAsset: "images/logo_background_white.png",
                  label: "Start New",
                  height: 40,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: COLOR_PRIMARY_DARK,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(0.0)),
                      ),
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                            child:
                            CreateJam(title: "", bandId: "", imageUrl: ""),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (questionCards.isEmpty && !loaded)
                const SkeletonHomeItem(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate a delay
    setState(() {
      loaded = false;
    });
    // await Future.delayed(Duration(seconds: 2));
    initialise();

    // Refresh your data
    //getNews();
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
  Future<bool> getCommunityQuestion() async {
    questionCards.clear();
    //getUserBands();
    questions = await FirebaseDBOperations.getQuestionsAsked();
    List<QuestionCard> fetchedQuestionCards = questions.map((question) {
      return QuestionCard(
        question: question,
        deleteCallback: (question){
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  void initialise() {
    getCommunityQuestion();
    getSharedPreferences();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  void getSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    showLiveALert = sharedPref.getBool(ALERT_EXPLORE_LIVE_SHARED_PREF)??true;
    if(showLiveALert) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return TutorialBox(
            boxType: BOX_TYPE_ALERT,
            autoUpdate: true,
            sharedPreferenceKey: ALERT_EXPLORE_LIVE_SHARED_PREF,
            tutorialImageAsset: "images/logo_background_white.png",
            tutorialMessage: TUTORIAL_MESSAGE_LIVE,
            tutorialMessageTitle: TUTORIAL_MESSAGE_LIVE_TITLE,
          );
        },
      );
    }
  }
}
