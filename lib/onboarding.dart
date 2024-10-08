import 'package:drumm_app/LoginPage.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'DrummOnBoardingSlider.dart';
import 'custom/transparent_slider.dart';

class OnBoarding extends StatelessWidget {
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  double assetSize = 200;
  OnBoarding({
    Key? key,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);

  String actionState = "Let\'s Drumm!";

  @override
  Widget build(BuildContext context) {
    double textSize = 36;
    Color offText = Colors.grey;
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.black,
        child: FlutterOnBoardingSlider(
          headerBackgroundColor: Colors.black,
          centerBackground: true,
          finishButtonText: 'Get Started',
          finishButtonTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: APP_FONT_BOLD,
          ),
          pageBackgroundColor: Colors.black,
          finishButtonStyle: FinishButtonStyle(
            backgroundColor: COLOR_PRIMARY_DARK,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(50.0),
              ),
            ),
          ),
          onFinish: () {
            final args = <String, dynamic>{
              'fields': "started_event_log",
            };

            var facebookAppEvents = FacebookAppEvents();
            facebookAppEvents.setAdvertiserTracking(enabled: true);
            facebookAppEvents
                .logEvent(name: "gettingstarted", parameters: args)
                .then((value) => print("Logged event"));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(
                          themeManager: themeManager,
                          analytics: analytics,
                          observer: observer,
                        )),
                (_) => false);
          },
          skipTextButton: const Text(
            'Skip',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          //trailing: Text('Login'),
          background: [
            if (false)
              Stack(
                children: [
                  Container(
                    height: 300, //MediaQuery.of(context).size.height,
                    child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_news.JPG?alt=media&token=3c3c4d6a-7063-4099-bf96-e31c8883a4b1",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                        ])),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                          Colors.transparent
                        ])),
                  ),
                ],
              ),
            if (false)
              Stack(
                fit: StackFit.passthrough,
                children: [
                  Container(
                    height: 300, //MediaQuery.of(context).size.height,
                    child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_people.png?alt=media&token=0391f610-0e59-4351-84de-8ed00cf697ee",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                        ])),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                          Colors.transparent
                        ])),
                  ),
                ],
              ),
            if (false)
              Stack(
                fit: StackFit.passthrough,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_bands.jpg?alt=media&token=34d97dc5-f31d-4045-af60-044ae1ed28d2",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                        ])),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.35),
                          Colors.transparent
                        ])),
                  ),
                ],
              ),
            Container(
              height: 500,
              width: 300,
              alignment: Alignment.center,
              child: Image.asset(
                height: assetSize,
                width: assetSize,
                fit: BoxFit.contain,
                color: Colors.white, //Color(0xD8181818),
                "images/grid.png",
              ),
            ),
            Container(
              height: 500,
              width: 300,
              alignment: Alignment.center,
              child: Image.asset(
                height: assetSize,
                width: assetSize,
                fit: BoxFit.contain,
                color: Colors.white, //Color(0xD8181818),
                "images/network.png",
              ),
            ),
            Container(
              height: 500,
              width: 300,
              alignment: Alignment.center,
              child: Image.asset(
                height: assetSize,
                width: assetSize,
                fit: BoxFit.contain,
                color: Colors.white, //Color(0xD8181818),
                "images/audio-waves-large.png",
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.45,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  height: assetSize,
                  width: assetSize,
                  fit: BoxFit.contain,
                  color: Colors.white, //Color(0xD8181818),
                  "images/logo_background_white.png",
                ),
              ),
            ),
          ],
          totalPage: 4,
          speed: 1.8,
          pageBodies: [
            Container(
              color: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height, //2,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: 'Discover News',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: textSize),
                        // children: <TextSpan>[
                        //   TextSpan(
                        //     text: 'News',
                        //     style: TextStyle(
                        //         fontFamily: APP_FONT_MEDIUM,
                        //         color: offText,
                        //         fontWeight: FontWeight.normal,
                        //         fontSize: textSize),
                        //   ),
                        // ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Dive into a world of latest and endless news topics and discover stories that matter to you.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: textSize / 2.25,
                          fontFamily: APP_FONT_MEDIUM,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height, //2,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: 'Explore Bands',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: textSize),
                        // children: <TextSpan>[
                        //   TextSpan(
                        //     text: 'News',
                        //     style: TextStyle(
                        //         fontFamily: APP_FONT_MEDIUM,
                        //         color: offText,
                        //         fontWeight: FontWeight.normal,
                        //         fontSize: textSize),
                        //   ),
                        // ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Join or create your band and connect with like-minded individuals and groups.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: APP_FONT_MEDIUM,
                          color: Colors.white70, fontSize: textSize / 2.25),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height, //2,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: 'Drumm Voice',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: textSize),
                        // children: <TextSpan>[
                        //   TextSpan(
                        //     text: 'News',
                        //     style: TextStyle(
                        //         fontFamily: APP_FONT_MEDIUM,
                        //         color: offText,
                        //         fontWeight: FontWeight.normal,
                        //         fontSize: textSize),
                        //   ),
                        // ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Start a drumm and engage in dynamic audio discussions with your band members on the latest news.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: APP_FONT_MEDIUM,
                          color: Colors.white70, fontSize: textSize / 2.25),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
