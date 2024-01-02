import 'package:drumm_app/LoginPage.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'custom/transparent_slider.dart';

class OnBoarding extends StatelessWidget {
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  OnBoarding({
    Key? key,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);

  String actionState = "Let\'s Drumm!";

  @override
  Widget build(BuildContext context) {
    double textSize = 28;
    Color offText = Colors.white.withOpacity(0.6);
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      home: OnBoardingSlider(
        headerBackgroundColor: Colors.black,
        centerBackground: true,
        finishButtonText: 'Get Started',
        finishButtonTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: APP_FONT_BOLD,
        ),
        pageBackgroundColor: Colors.black,
        finishButtonStyle:  FinishButtonStyle(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
        onFinish: (){
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
        skipTextButton: const Text('Skip',style: TextStyle(color: Colors.white,),),
        //trailing: Text('Login'),
        background: [
          Container(
            height: MediaQuery.of(context).size.height / 1.75,
            child: Container(
              alignment: Alignment.center,
              child: ClipRRect(
                  child: Lottie.asset(
                    'images/breaking_news.json',
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.75,
            child: Container(
              alignment: Alignment.center,
              child: Lottie.asset('images/wave_drumm.json',
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.contain),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.75,
            child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                    child: Lottie.asset('images/drumm_band.json',
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment(1, -1))),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.75,
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                height: 200,
                width: 200,
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

            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Discover ',
                    style: TextStyle(
                        fontFamily: APP_FONT_MEDIUM,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Breaking ',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            color: offText,
                            fontWeight: FontWeight.normal,
                            fontSize: textSize),
                      ),
                      TextSpan(
                        text: 'News',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            color: offText,
                            fontWeight: FontWeight.normal,
                            fontSize: textSize),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Drumm',
                    style: TextStyle(
                        fontFamily: APP_FONT_MEDIUM,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: ' with the community',
                          style: TextStyle(
                            color: offText,
                            fontWeight: FontWeight.normal,
                            fontSize: textSize,
                            fontFamily: APP_FONT_MEDIUM,
                            fontStyle: FontStyle.normal,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Join ',
                    style: TextStyle(
                        fontFamily: APP_FONT_MEDIUM, color: offText, fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Bands',
                          style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            fontSize: textSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                          text: ' of Shared Passions',
                          style: TextStyle(
                            color: offText,
                            fontFamily: APP_FONT_MEDIUM,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
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
    );
  }
}