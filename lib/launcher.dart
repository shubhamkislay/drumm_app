import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/transparent_slider.dart';
import 'package:drumm_app/model/AiVoice.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_onboarding_slider/background_final_button.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:magnifying_glass/magnifying_glass.dart';
import 'package:drumm_app/bands_page.dart';
import 'package:drumm_app/custom/ai_summary.dart';
import 'package:drumm_app/custom/create_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/explore_page.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/search_page.dart';
import 'package:drumm_app/swipe_page.dart';
import 'package:drumm_app/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BottomJamWindow.dart';
import 'BottomTabBar.dart';
import 'InterestPage.dart';
import 'TutorialScreen.dart';
import 'UserProfileIcon.dart';
import 'ask_page.dart';
import 'custom/bottom_sheet.dart';
import 'custom/create_jam_bottom_sheet.dart';
import 'custom/helper/circular_reveal_clipper.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/listener/connection_listener.dart';
import 'custom/rounded_button.dart';
import 'jam_room_page.dart';
import 'my_home_page.dart';
import 'news_feed.dart';
import 'theme/theme_constants.dart';
import 'theme/theme_manager.dart';

class LauncherPage extends StatefulWidget {
  ThemeManager themeManager;
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;
  LauncherPage({
    super.key,
    required this.themeManager,
    required this.analytics,
    required this.observer,
  });

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage>
    with TickerProviderStateMixin {
  GlobalKey<HomeFeedPageState> homeFeedKey = GlobalKey<HomeFeedPageState>();

  late TabController tabController;
  double iconPadding = 6;
  double textSize = 28;
  double marginHeight = 200;
  late AnimationController _animationController;
  Color disableColor =
      Colors.grey.shade800; //Color(0xff4d4d4d); //Colors.grey.shade800;

  double tabsWidthDivision = 8.5; //Value will be 10 for Wave mode

  bool userConnected = false;

  late Jam currentJam = Jam();
  bool openDrumm = false;
  bool isTutorialDone = true;

  Drummer drummer = Drummer();

  @override
  Widget build(BuildContext context) {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1250),
      upperBound: 1.0,
    );
    _animationController.forward();
    tabController = TabController(
        length: 5, vsync: this, animationDuration: Duration(milliseconds: 0));
    FirebaseDBOperations.searchArticles("");
    return AnimatedBuilder(
      builder: (BuildContext context, Widget? child) {
        return ClipPath(
          clipper: CircleRevealClipper(
            fraction: _animationController.value,
          ),
          child: child,
        );
      },
      animation: _animationController,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            FrostedBottomBar(
              opacity: 1,
              sigmaX: 200,
              sigmaY: 200,
              bottom: 0,
              hideOnScroll: false,
              //currentPage == 0 ? true:false,
              width: MediaQuery.of(context).size.width,
              bottomBarColor: Colors.black, //Color(0xff101010),

              body: (context, controller) => Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: TabBarView(
                        dragStartBehavior: DragStartBehavior.down,
                        physics:
                            NeverScrollableScrollPhysics(), //const BouncingScrollPhysics(),
                        children: [
                          NewsFeed(),
                          ExplorePage(),
                          SwipePage(),
                          BandSearchPage(),
                          UserProfilePage(),
                        ],
                        controller: tabController,
                      ),
                    ),
                  ),
                  BottomJamWindow(),
                  SizedBox(height: 80), //Wave Mode it was 88
                ],
              ),
              child: BottomTabBar(tabController: tabController,),
            ),
            TutotrialManager(),
          ],
        ),
      ),
    );
  }





  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
    ConnectionListener.onConnectionChanged = null;
  }

  void refreshHomePage() {
    homeFeedKey.currentState?.getToTop();
  }
}



class TutotrialManager extends StatefulWidget {

  TutotrialManager({ super.key});

  @override
  State<TutotrialManager> createState() => _TutotrialManagerState();
}

class _TutotrialManagerState extends State<TutotrialManager> {
  bool isTutorialDone = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setOnboarded();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (!isTutorialDone)?
        Expanded(
          child: TutorialScreen(finishTutorial: () {
            finishedTutorial();
          },),
        ):Container(height: 0,width: 0,),
    );
  }

  void finishedTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTutorialDone = true;
    });
    await prefs.setBool('isTutorialDone', true);
  }

  void setOnboarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkTutorial = await prefs.getBool('isTutorialDone') ?? false;
    setState(() {
      isTutorialDone = checkTutorial;
      if (!isTutorialDone) {
        playWelcomeAudio();
      }
    });
    await prefs.setBool('isOnboarded', true);
  }

  void playWelcomeAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    AiVoice aiVoice = await FirebaseDBOperations.getAiVoice("welcome");
    audioPlayer.setUrl(aiVoice.aiVoiceUrl ?? "");
    audioPlayer.play();
  }
}

