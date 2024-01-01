import 'package:auto_size_text/auto_size_text.dart';
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

import 'create_band.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/band.dart';
import 'model/jam.dart';
import 'model/live_drumm_card.dart';

class LiveDrumms extends StatefulWidget {
  @override
  State<LiveDrumms> createState() => LiveDrummsState();
}

class LiveDrummsState extends State<LiveDrumms>
    with AutomaticKeepAliveClientMixin<LiveDrumms> {
  List<DrummCard> drummCards = [];
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
                              if (false)
                                Container(
                                    padding: EdgeInsets.all(2),
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
                                        child: Icon(Icons.language, size: 42))),
                              SizedBox(
                                width: 0,
                              ),
                              AutoSizeText(
                                "Live",
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
                        if (drummCards.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: GridView.count(
                                crossAxisCount: 2, // Number of columns
                                childAspectRatio: 0.8,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: drummCards),
                          ),
                        if (drummCards.isEmpty && loaded)
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(32),
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Text(
                                "There are currently no live drumms",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: APP_FONT_MEDIUM,
                                ),
                              ),
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
                if (false)
                  Container(
                    alignment: Alignment.bottomLeft,
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black])),
                  ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0.0)),
                      ),
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
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
              if (drummCards.isEmpty && !loaded)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.all(36),
                          child: Lottie.asset('images/wave_drumm.json',
                              fit: BoxFit.contain, width: double.maxFinite)),
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.shade900.withOpacity(0.75),
                      )
                    ],
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

  Future<void> getOpenDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getOpenDrummsFromBands(); //getUserBands();
    openDrumms = fetchedDrumms;
    openDrummCards = openDrumms.map((jam) {
      return DrummCard(
        jam,
        open: true,
      );
    }).toList();

    setState(() {
      drummCards = drummCards + openDrummCards;
      loaded = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  void initialise() {
    getBandDrumms();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
