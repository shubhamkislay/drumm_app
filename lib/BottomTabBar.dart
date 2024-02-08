import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'UserProfileIcon.dart';
import 'custom/constants/Constants.dart';
import 'custom/create_jam_bottom_sheet.dart';
import 'custom/listener/connection_listener.dart';

class BottomTabBar extends StatefulWidget {
  TabController tabController;
  BottomTabBar({required this.tabController});

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int currentPage = 0;
  Color disableColor =
      Colors.white;
  double tabsWidthDivision = 8.5;
  @override
  Widget build(BuildContext context) {
    return Container(
       //COLOR_PRIMARY_DARK,
      decoration: const BoxDecoration(
        color: COLOR_BACKGROUND,
      ),
      child: SafeArea(
        top: false,
        child: TabBar(
          enableFeedback: true,
          padding: const EdgeInsets.only(bottom: 0, top: 8),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.transparent;
            },
          ),
          controller: widget.tabController,
          indicator: const UnderlineTabIndicator(
            borderSide:
            BorderSide(color: Colors.transparent, width: 8),
            //insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
          tabs: [
            Container(
              width: MediaQuery.of(context).size.width /
                  tabsWidthDivision,
              padding: EdgeInsets.only(top: 0, left: 0),
              child: Image.asset(
                  color: currentPage == 0
                      ? Colors.white
                      :disableColor,
                  width: 24,
                  currentPage == 0
                      ? "images/hut_btn_active.png"
                      : "images/hut_btn.png",
                  height: 24),
            ),
            Container(
              //height: 26,
              width: MediaQuery.of(context).size.width /
                  tabsWidthDivision,
              child: Image.asset(
                color: (currentPage == 1)
                    ? Colors.white
                    : disableColor,
                width: 30,
                currentPage == 1
                    ? "images/discovery_tapped.png"
                    : "images/discovery.png",
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            if (true)
              Container(
                width: MediaQuery.of(context).size.width /
                    tabsWidthDivision,
                padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  //color: currentPage == 1 ?  Color(COLOR_PRIMARY_VAL): widget.themeManager.themeMode == ThemeMode.dark ?Colors.white38: Colors.black.withOpacity(0.25),
                    color: disableColor,
                    width: 36,
                    'images/audio-waves.png',//"images/plus_btn.png",
                    height: 36),
              ),
            /*
                      Wave Mode icon
                      */
            Container(
              width: MediaQuery.of(context).size.width /
                  tabsWidthDivision,
              padding: EdgeInsets.only(top: 0, right: 0),
              alignment: Alignment.bottomCenter,
              // padding: EdgeInsets.symmetric(
              //     vertical: iconPadding, horizontal: iconPadding),
              child: Image.asset(
                  alignment: Alignment.bottomCenter,
                  color: (currentPage == 3)
                      ? Colors.white
                      : disableColor,
                  width: 32,
                  currentPage == 3
                      ? "images/team_active.png"
                      : "images/team_inactive.png",
                  height: 32),
            ),
            UserProfileIcon(),
          ],
          onTap: (index) {
            Vibrate.feedback(FeedbackType.selection);
            if (index !=
                2 //2 This should be 2 for Wave Mode. Currently it's commented
            ) {
              setState(() {
              if (currentPage == 0 && index == 0) {
                print("Calling refresh $currentPage");
                //refreshHomePage();
              }
              currentPage = index;
              print("CurrentPage $currentPage");
              });
            } else {
              widget.tabController.animateTo(currentPage);
              Vibrate.feedback(FeedbackType.selection);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: COLOR_PRIMARY_DARK,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0.0)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom:
                        MediaQuery.of(context).viewInsets.bottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(0.0)),
                      child: CreateJam(
                          title: "", bandId: "", imageUrl: ""),
                    ),
                  );
                },
              );
            }
          },
          isScrollable: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    widget.tabController.dispose();
    super.dispose();
    ConnectionListener.onConnectionChanged = null;
  }
}
