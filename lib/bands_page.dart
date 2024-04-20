import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/drumm_card.dart';
import 'package:drumm_app/skeleton_band.dart';
import 'package:drumm_app/theme/theme_constants.dart';

import 'create_band.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'explore_bands_page.dart';
import 'model/band.dart';
import 'model/jam.dart';

class BandSearchPage extends StatefulWidget {
  @override
  State<BandSearchPage> createState() => BandSearchPageState();
}

class BandSearchPageState extends State<BandSearchPage>
with AutomaticKeepAliveClientMixin<BandSearchPage>{
  List<BandImageCard> cards = [];
  List<DrummCard> drummCards = [];
  List<Band> bands = [];
  List<Jam> drumms = [];
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      body: Stack(
        children: [
          if(!loaded)
            SkeletonBand(),
          if (loaded)
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (drummCards.length > 0)
                        Container(
                          alignment: Alignment.centerLeft,
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Stack(
                            children: [
                              if (drummCards.length > 0)
                                AutoSizeText(
                                  "Live",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (drummCards.length > 0)
                        Container(
                          height: 175,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: drummCards.length,
                              padding: EdgeInsets.all(8),
                              itemBuilder: (context, index) =>
                                  drummCards.elementAt(index),
                              separatorBuilder: (context, index) => SizedBox(
                                width: 8,
                              )),
                        ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            AutoSizeText(
                              "Your Bands",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_BOLD,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cards.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: GridView.count(
                              crossAxisCount: 2, // Number of columns
                              childAspectRatio: 0.8,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: cards),
                        ),
                      if (cards.isEmpty)
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(32),
                            height: MediaQuery.of(context).size.height*0.7,
                            child: Text("You are not part of any band.\n"
                                "Tap the button at the bottom to explore the bands.",textAlign: TextAlign.center,),
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
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 175,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,
                        colors: [
                          Colors.transparent,
                          COLOR_BACKGROUND
                        ])),
              ),
            ),
          ),
          if (loaded)
          Container(
            width: double.infinity,
            alignment: /*jamImageCards.isNotEmpty ?*/
            Alignment.bottomCenter, //:Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconLabelButton(
                  label: 'Explore Bands',
                  backgroundColor: Colors.blue.shade700,
                  textColor: Colors.white,
                  assetColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExploreBandsPage(),
                      ),
                    );
                  },
                  imageAsset: 'images/team_active.png',
                  height: 40,
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateBand(),
                      ),
                    );
                  },
                  child: Container(
                    child: Icon(Icons.add),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade700,),
                  ),
                )
              ],
            ),
          ),
        ],
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

  void getUserBands() async {
    List<Band> fetchedBands =
        await FirebaseDBOperations.getBandByUser(); //getUserBands();
    bands = fetchedBands;
    setState(() {
      cards = bands.map((band) {
        return BandImageCard(
          band,
          onlySelectable: false,
        );
      }).toList();
      loaded = true;
    });
  }

  Future<void> getBandDrumms() async {
    List<Jam> fetchedDrumms =
        await FirebaseDBOperations.getDrummsFromBands(); //getUserBands();
    drumms = fetchedDrumms;



    setState(() {
      loaded = true;
      drummCards = drumms.map((jam) {
        return DrummCard(
          jam,
        );
      }).toList();

      print("drummCards returned");
      setState(() {
        loaded = true;

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  void initialise(){
    getUserBands();
    // getBandDrumms().then((value) {
    //   setState(() {
    //     print("Loaded list//////////");
    //     loaded = true;
    //   });
    // });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
