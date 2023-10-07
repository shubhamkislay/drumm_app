import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/notification_item.dart';
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
import 'custom/helper/firebase_db_operations.dart';
import 'model/band.dart';
import 'model/jam.dart';
import 'model/live_drumm_card.dart';

class NotificationWidget extends StatefulWidget {
  @override
  State<NotificationWidget> createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget>
    with AutomaticKeepAliveClientMixin<NotificationWidget>{
  List<DrummCard> drummCards = [];
  List<NotificationItem>? notiList = [];
  List<DrummCard> userDrummCards = [];
  List<Band> bands = [];
  List<Jam> drumms = [];
  List<Jam> openDrumms = [];
  List<DrummCard> openDrummCards = [];
  bool loaded = false;

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
                          EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if(false)  Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade900,
                                            Colors.grey.shade900
                                          ]
                                      )
                                  ),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: Colors.grey.shade900,
                                      ),
                                      child: Icon(Icons.language,size: 42))),
                              SizedBox(width: 0,),
                              Expanded(
                                child: AutoSizeText(
                                  "Notifications",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: 'alata',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: GestureDetector(
                                    onTap: (){
                                      clearNotifications();
                                    },
                                    child: Text("Clear",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),)),
                              )
                            ],
                          ),
                        ),
                        if (false &&notiList!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: GridView.count(
                                crossAxisCount: 1, // Number of columns
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                children: notiList??[]),
                          ),

                        if (notiList!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: notiList?.length??0,
                                padding: EdgeInsets.all(4),
                                itemBuilder: (context, index) =>
                                    notiList?.elementAt(index),
                                separatorBuilder: (context, index) =>
                                    SizedBox(
                                      height: 12,
                                    )),
                          ),

                        if (notiList!.isEmpty&&loaded)
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(32),
                              height: MediaQuery.of(context).size.height*0.7,
                              child: Text("Nothing much going on here",textAlign: TextAlign.center,),
                            ),
                          ),
                        SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (loaded)
                if(false)Container(
                  alignment: Alignment.bottomLeft,
                  height: 100,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black])),
                ),
              if (drummCards.isEmpty&&!loaded)
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
      loaded=false;
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

  void initialise(){
    getNotifications();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  void getNotifications() async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");
    List<Jam> fetchedJams = [];

    int notifLen = notifications?.length??0;

    if(notifLen>0) {
      notifications = new List.from(notifications?.reversed as Iterable);

      setState(() {
        notiList = notifications?.map((msg) {
          return NotificationItem(message: msg,
          );
        }).toList();
        loaded = true;
      });
    }
    else
      setState(() {
        notiList = [];
        loaded = true;
      });

    return;

    for(String jamJson in notifications!){
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

      loaded=true;
    });
  }

  void clearNotifications() async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    notiPref.setStringList("notifications", []);

    setState(() {
      notiList = [];
      loaded=true;
    });
  }
}
