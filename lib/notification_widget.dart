import 'dart:convert';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/notification_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/drumm_card.dart';
import 'package:drumm_app/skeleton_band.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'create_band.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/band.dart';
import 'model/jam.dart';
import 'model/live_drumm_card.dart';

class NotificationWidget extends StatefulWidget {
  @override
  State<NotificationWidget> createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget>
    with AutomaticKeepAliveClientMixin<NotificationWidget> {
  List<DrummCard> drummCards = [];
  List<NotificationItem>? notiList = [];
  List<DrummCard> userDrummCards = [];
  List<Band> bands = [];
  List<Jam> drumms = [];
  List<Jam> openDrumms = [];
  List<DrummCard> openDrummCards = [];
  bool loaded = false;
  late SharedPreferences notiPref;

  int notifactionValue = 1;

  bool notify = true;

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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: GestureDetector(
                              onTap: () {
                                clearNotifications();
                              },
                              child: const Text(
                                "Clear",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                  fontFamily: APP_FONT_MEDIUM,
                                ),
                              )),
                        ),
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
                              const SizedBox(
                                width: 0,
                              ),
                              const Expanded(
                                child: AutoSizeText(
                                  "Notifications",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontFamily: APP_FONT_MEDIUM,
                                    //fontFamily: 'alata',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: ToggleSwitch(
                                  minWidth: 60.0,
                                  cornerRadius: 20.0,
                                  activeBgColors: [
                                    [Colors.redAccent],
                                    [Colors.white!]
                                  ],
                                  activeFgColor: Colors.black,
                                  inactiveBgColor: Colors.grey.shade900,
                                  inactiveFgColor: Colors.white,
                                  initialLabelIndex: notify ? 1 : 0,
                                  totalSwitches: 2,
                                  labels: ['Off', 'On'],
                                  radiusStyle: true,
                                  customTextStyles: [
                                    const TextStyle(fontWeight: FontWeight.bold,fontFamily: APP_FONT_BOLD,)
                                  ],
                                  onToggle: (index) {
                                    Vibrate.feedback(FeedbackType.impact);
                                    print('switched to: $index');
                                    setNotify(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (false && notiList!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: GridView.count(
                                crossAxisCount: 1, // Number of columns
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                children: notiList ?? []),
                          ),
                        if (notiList!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notiList?.length ?? 0,
                                padding: const EdgeInsets.all(4),
                                itemBuilder: (context, index) =>
                                    notiList?.elementAt(index),
                                separatorBuilder: (context, index) => const SizedBox(
                                      height: 12,
                                    )),
                          ),
                        if (notiList!.isEmpty && loaded)
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(32),
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: const Text(
                                "Nothing much going on here",
                                style: TextStyle(
                                  fontFamily: APP_FONT_LIGHT,
                                ),
                                textAlign: TextAlign.center,
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
              if (drummCards.isEmpty && !loaded)
                Center(
                  child: Container(
                      child: Lottie.asset('images/animation_loading.json',
                          fit: BoxFit.contain, width: double.maxFinite)),
                ),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initialise();
  }

  void initialise() async {
    notiPref = await SharedPreferences.getInstance();
    notify = notiPref.getBool("notify") ?? true;

    getNotifications();
  }

  Widget rollingIconBuilder(int? value, bool foreground) {
    return notifactionValue == 1
        ? const Icon(Icons.access_time_rounded)
        : const Icon(Icons.ac_unit);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  void getNotifications() async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");
    List<Jam> fetchedJams = [];

    int notifLen = notifications?.length ?? 0;

    if (notifLen > 0) {
      notifications = new List.from(notifications?.reversed as Iterable);

      setState(() {
        notiList = notifications?.map((msg) {
          return NotificationItem(
            message: msg,
          );
        }).toList();
        loaded = true;
      });
    } else {
      setState(() {
        notiList = [];
        loaded = true;
      });
    }

    return;

    for (String jamJson in notifications!) {
      Map<String, dynamic> json = jsonDecode(jamJson);
      Jam jam = Jam.fromJson(json);
      fetchedJams.add(jam);
    }
    fetchedJams = new List.from(fetchedJams.reversed);

    setState(() {
      drummCards = fetchedJams.map((jam) {
        return DrummCard(
          jam,
        );
      }).toList();

      loaded = true;
    });
  }

  void clearNotifications() async {
    // SharedPreferences notiPref = await SharedPreferences.getInstance();
    notiPref.setStringList("notifications", []);

    setState(() {
      notiList = [];
      loaded = true;
    });
  }

  void setNotify(int? index) {
    if (index == 1) {
      notiPref.setBool("notify", true);
      notify = true;
      FirebaseDBOperations.subscribeToUserBands();
    } else {
      notiPref.setBool("notify", false);
      notify = false;
      try {
        FirebaseMessaging.instance.deleteToken();
        FirebaseMessaging.instance.getToken().then((token) => FirebaseDBOperations.updateDrummerToken(token??""));
      }catch(e){
      }
      //FirebaseDBOperations.unSubscribeToUserBands();
    }
  }
}
