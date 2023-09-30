import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
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

import 'InterestPage.dart';
import 'ask_page.dart';
import 'custom/bottom_sheet.dart';
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

  late int currentPage;
  late TabController tabController;
  double iconPadding = 6;

  Color disableColor = Color(0xff4d4d4d); //Colors.grey.shade800;

  double tabsWidthDivision = 4; //Value will be 10 for Wave mode
  late AnimationController rotationAnimcontroller;

  bool userConnected = false;
  bool micMute = false;

  late Jam currentJam = Jam();
  bool openDrumm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FrostedBottomBar(
        opacity: 1,
        sigmaX: 200,
        sigmaY: 200,
        bottom: 0,
        hideOnScroll: false,
        //currentPage == 0 ? true:false,
        width: MediaQuery.of(context).size.width,
        bottomBarColor: Colors.black,//Color(0xff101010),

        body: (context, controller) => Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0,),
                child: TabBarView(
                  dragStartBehavior: DragStartBehavior.down,
                  physics:
                      NeverScrollableScrollPhysics(), //const BouncingScrollPhysics(),
                  children: [
                    // HomeFeedPage(
                    //   key: homeFeedKey,
                    //   userConnected: userConnected,
                    //   title: "Drumm",
                    //   themeManager: widget.themeManager,
                    //   scrollController: controller,
                    //   analytics: widget.analytics,
                    //   observer: widget.observer, tag: 'Drumm',
                    // ),
                    NewsFeed(),
                    ExplorePage(),
                    /**
                     * Wave Mode
                     *  Container(),
                     */

                    BandSearchPage(),
                    if (false)
                      InterestsPage(
                        observer: widget.observer,
                        analytics: widget.analytics,
                        themeManager: widget.themeManager,
                      ),
                   if(false) UserProfilePage()
                    // SwipePage(),
                  ],
                  controller: tabController,
                ),
              ),
            ),
            if (userConnected)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(0.0)),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(0.0)),
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
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 0,),
                  margin: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                  decoration: BoxDecoration(
                      color: COLOR_PRIMARY_DARK,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade900, width: 1)),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: currentJam.imageUrl ?? "",
                            fit: BoxFit.cover,
                            height: 42,
                            width: 42,
                            errorWidget: (context,url,error) => Container(color:COLOR_PRIMARY_DARK),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Text(
                          "${currentJam.title}",
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                              fontSize: 14),
                        ),
                      )),
                     if(false) RoundedButton(
                        height: 46,
                        padding: 12,
                        assetPath: micMute ? "images/mic_off.png":"images/mic_on.png",
                        color: Colors.white,
                        bgColor: Colors.white12,
                        onPressed: () {
                          setState(() {
                            if(micMute)
                              micMute = false;
                            else
                              micMute = true;

                            ConnectToChannel.setMute(micMute);
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: (){
                          ConnectToChannel.leaveChannel();
                          FlutterCallkitIncoming.endAllCalls();
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(18),),
                          child: Transform.rotate(angle: 180 * 3.1415927 / 180,
                          child: Image.asset("images/logout.png",fit: BoxFit.contain,color: Colors.white,)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            SizedBox(height: 80), //Wave Mode it was 88
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            color: Colors.black,//COLOR_PRIMARY_DARK,
            child: TabBar(
              enableFeedback: true,
              padding: EdgeInsets.only(bottom: 0, top: 8),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              controller: tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.transparent, width: 8),
                //insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              tabs: [
                Container(
                  width: MediaQuery.of(context).size.width / tabsWidthDivision,
                  padding: EdgeInsets.only(top: 0, left: 0),
                  child: Image.asset(
                      color: currentPage == 0
                          ? widget.themeManager.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black
                          : widget.themeManager.themeMode == ThemeMode.dark
                              ? disableColor
                              : Colors.black.withOpacity(0.25),
                      width: 26,
                      currentPage == 0
                          ? "images/hut_btn_active.png"
                          : "images/hut_btn.png",
                      height: 26),
                ),
                Container(
                  height: 26,
                  width: MediaQuery.of(context).size.width / tabsWidthDivision,
                  child: Image.asset(
                    color: currentPage == 1
                        ? widget.themeManager.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black
                        : widget.themeManager.themeMode == ThemeMode.dark
                            ? disableColor
                            : Colors.black.withOpacity(0.25),
                    width: 13,
                    "images/search_btn.png",
                    height: 13,
                    fit: BoxFit.contain,
                  ),
                ),
                if (false)
                  Container(
                    width: MediaQuery.of(context).size.width / 5,
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        // gradient: LinearGradient(colors: [
                        //   Colors.white,//Colors.blue.shade300,
                        //   Colors.blue.shade500,
                        //   Colors.blue.shade800
                        // ]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.transparent, //.withOpacity(0.75),
                            spreadRadius: 8,
                            blurRadius: 8,
                            blurStyle: BlurStyle.outer,
                            offset: Offset(
                                1, -1), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: RotationTransition(
                        turns: Tween(
                                begin: 0.0,
                                end: 0.05) //Tween(begin: 0.0, end: 1.0)
                            .animate(rotationAnimcontroller),
                        child: Image.asset(
                            //color: currentPage == 1 ?  Color(COLOR_PRIMARY_VAL): widget.themeManager.themeMode == ThemeMode.dark ?Colors.white38: Colors.black.withOpacity(0.25),
                            color: disableColor,
                            width: 28,
                            "images/wave.png",
                            height: 28),
                      ),
                    ),
                  ),
                /*
                Wave Mode icon
                */
                Container(
                  width: MediaQuery.of(context).size.width / tabsWidthDivision,
                  padding: EdgeInsets.only(top: 0, right: 0),
                  alignment: Alignment.bottomCenter,
                  // padding: EdgeInsets.symmetric(
                  //     vertical: iconPadding, horizontal: iconPadding),
                  child: Image.asset(
                      alignment: Alignment.bottomCenter,
                      color: currentPage == 2
                          ? widget.themeManager.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black
                          : widget.themeManager.themeMode == ThemeMode.dark
                              ? disableColor
                              : Colors.black.withOpacity(0.25),
                      width: 40,
                      currentPage == 2
                          ? "images/team_active.png"
                          : "images/team_inactive.png",
                      height: 40),
                ),
               if(false) Container(
                  height: 26,
                  width: MediaQuery.of(context).size.width / tabsWidthDivision,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                    child: Image.asset(
                      color: currentPage == 3
                          ? widget.themeManager.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black
                          : widget.themeManager.themeMode == ThemeMode.dark
                              ? disableColor
                              : Colors.black.withOpacity(0.25),
                      width: 12,
                      currentPage == 3
                          ? "images/user_profile_active.png"
                          : "images/user_profile_inactive.png",
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
              onTap: (index) {
                if (index !=
                        4 //2 This should be 2 for Wave Mode. Currently it's commented
                    ) {
                  setState(() {
                    if (currentPage == 0 && index == 0) {
                      print("Calling refresh $currentPage");
                      refreshHomePage();
                    }
                    currentPage = index;
                    print("CurrentPage $currentPage");
                  });
                } else {
                  tabController.animateTo(currentPage);
                  // showModalBottomSheet(
                  //   backgroundColor: Colors.transparent,
                  //   context: context,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius:
                  //         BorderRadius.vertical(top: Radius.circular(20.0)),
                  //   ),
                  //   builder: (BuildContext context) {
                  //     return ClipRRect(
                  //       borderRadius:
                  //           BorderRadius.vertical(top: Radius.circular(20.0)),
                  //       child: CreateBottomSheet(),
                  //     );
                  //   },
                  // );
                  Vibrate.feedback(FeedbackType.impact);
                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, _) {
                        return SwipePage();
                      }));
                }
              },
              isScrollable: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    tabController = TabController(
        length: 3, vsync: this, animationDuration: Duration(milliseconds: 0));

    FirebaseDBOperations.searchArticles("");

    rotationAnimcontroller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    listenToJamState();
  }

  void listenToJamState() {
    ConnectionListener.onConnectionChanged = (connected, jam,open) {
      // Handle the channelID change here
     // print("onConnectionChanged called in Launcher");
      setState(() {
        // Update the UI with the new channelID
        openDrumm = open;
        currentJam = jam;
        userConnected = connected;
        micMute = ConnectToChannel.getMuteState();
      });
    };
  }

  @override
  void dispose() {
    // TODO: implement dispose

    tabController.dispose();
    rotationAnimcontroller.dispose();
    super.dispose();
    ConnectionListener.onConnectionChanged = null;
  }

  void refreshHomePage() {
    homeFeedKey.currentState?.getToTop();
  }
}
