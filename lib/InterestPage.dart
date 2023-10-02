import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/helper/image_uploader.dart';
import 'launcher.dart';
import 'model/band_image_card.dart';

class InterestsPage extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final ThemeManager themeManager;

  const InterestsPage({
    required this.observer,
    required this.analytics,
    required this.themeManager,
  });

  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  List<String> selectedInterests = [];
  List<Band> selectedBands = [];

  int minInterests = 1;

  final List<String> interests = [
    "GENERAL",
    "BUSINESS",
    "ENTERTAINMENT",
    //"environment",
    //"FOOD",
    "HEALTH",
    "POLITICS",
    "SCIENCE",
    "SPORTS",
    "TECHNOLOGY",
    // "top",
    // "tourism",
    // "world",
  ];

  List<GestureDetector> bandCards = [];
  List<Band> bands = [];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        if (selectedInterests.length < 7) {
          selectedInterests.add(interest);
        } else {
          // Show a toast or display an error message indicating the limit has been reached
          print('Maximum selection limit reached');
        }
      }
    });
  }

  void selectBand(Band band) {
    setState(() {
      if (selectedBands.contains(band)) {
        selectedBands.remove(band);
      } else {
        if (selectedBands.length < 7) {
          selectedBands.add(band);
        } else {
          // Show a toast or display an error message indicating the limit has been reached
          print('Maximum selection limit reached');
        }
      }
      toggleInterest(band.name ?? "");
    });
  }

  void getUserBands() async {
    List<Band> bandList = await FirebaseDBOperations.getBandByUser();

    if(bandList.length>0) {
      _onboardingComplete();
    }
    else {
      List<Band> fetchedBands =
      await FirebaseDBOperations.getOnboardingBands(); //getUserBands();
      bands = fetchedBands;
      setState(() {
        bandCards = bands
            .map(
              (band) =>
              GestureDetector(
                onTap: () {
                  selectBand(band);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    color: selectedBands.contains(band)
                        ? Colors.blue //Color(COLOR_PRIMARY_VAL)
                        : Colors.grey.shade900,
                    // child: BandImageCard(
                    //   band,
                    //   onlySelectable: true,
                    // ),
                    child: Text("${band.name}"),
                  ),
                ),
              ),
        )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 42, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 36.0),
            Image.asset(
                alignment: Alignment.center,
                color: Colors.white,
                width: 76,
                "images/team_active.png",
                height: 76),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 30,
              ),
              child: Text(
                'Select the bands that you\'re passionate or curious about',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 36.0),
            if (false)
              Wrap(
                spacing: 14.0,
                runSpacing: 24.0,
                children: interests
                    .map(
                      (interest) => GestureDetector(
                        onTap: () => toggleInterest(interest.toLowerCase()),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color:
                              selectedInterests.contains(interest.toLowerCase())
                                  ? Colors.blue //Color(COLOR_PRIMARY_VAL)
                                  : Colors.grey.shade900,
                          child: Text(
                            "#$interest\t",
                            style: TextStyle(
                                color: selectedInterests
                                        .contains(interest.toLowerCase())
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            if (false) SizedBox(height: 16.0),
            if (false)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: GridView.count(
                    crossAxisCount: 2, // Number of columns
                    childAspectRatio: 0.8,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: bandCards),
              ),
            Center(
              child: Wrap(
                spacing: 18.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: bands
                    .map(
                      (band) => GestureDetector(
                        onTap: () => selectBand(band),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: COLOR_PRIMARY_DARK,
                                    borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: selectedBands.contains(band)
                                      ? Colors.white //Color(COLOR_PRIMARY_VAL)
                                      : Colors.grey.shade900, width: 2.5)
                                ),

                                child: Container(
                                    height: 125,
                                    width: 125,
                                    margin: EdgeInsets.all(2),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: modifyImageUrl(band.url ?? "","300x300")),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${band.name}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: selectedBands.contains(band)
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 100.0),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor:  Colors.blue,
      //   onPressed: () {
      //     // Handle the selected interests and navigate to the next page`
      //     if (selectedInterests.length >= minInterests) {
      //       _onboardingComplete(context, selectedInterests);
      //       print('Selected Interests: $selectedInterests');
      //     } else {
      //       print('Select at least $minInterests interests');
      //     }
      //   },
      //   label: Container(
      //     child: Text(
      //       ''
      //     ),
      //   ),
      //   icon: Icon(
      //     Icons.done,
      //     color: Colors.white,
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedInterests.length >= minInterests) {
            _onboardingComplete();
            print('Selected Interests: $selectedInterests');
          } else {
            print('Select at least $minInterests interests');
            setState(() {
              AnimatedSnackBar.material(
                'Choose at least one band to continue',
                type: AnimatedSnackBarType.error,
                mobileSnackBarPosition: MobileSnackBarPosition.bottom,
              ).show(context);
            });
          }
        },
        child: Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    //getPrefs();
    super.initState();
    getUserBands();
  }

  void _onboardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    // await prefs.setStringList('interestList', interestList);
    joinBand();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LauncherPage(
          themeManager: widget.themeManager,
          analytics: widget.analytics,
          observer: widget.observer,
        ),
      ),
    );
  }

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userInterests = prefs.getStringList('interestList')!;
    setState(() {
      selectedInterests = userInterests;
    });
  }

  void joinBand() {
    for (Band band in selectedBands) {
      FirebaseDBOperations.joinBand(band);
    }
  }
}
