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
    double textSize = 32;
    Color offText = Colors.grey;
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
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: Image.network("https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_news.JPG?alt=media&token=3c3c4d6a-7063-4099-bf96-e31c8883a4b1",fit: BoxFit.cover,height: MediaQuery.of(context).size.height,),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.65),
                    ]
                  )
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.75),
                          Colors.transparent
                        ]
                    )
                ),
              ),
            ],
          ),
          Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: Image.network("https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_people.png?alt=media&token=0391f610-0e59-4351-84de-8ed00cf697ee",fit: BoxFit.cover,height: MediaQuery.of(context).size.height,),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.65),

                        ]
                    )
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.75),
                          Colors.transparent
                        ]
                    )
                ),
              ),
            ],
          ),
          Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: Image.network("https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Fonboarding_bands.jpg?alt=media&token=34d97dc5-f31d-4045-af60-044ae1ed28d2",fit: BoxFit.cover,height: MediaQuery.of(context).size.height,),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.65),

                        ]
                    )
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.75),
                          Colors.transparent
                        ]
                    )
                ),
              ),
            ],
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
            color: Colors.transparent,
            child: Container(

              height: MediaQuery.of(context).size.height/2,
              color: Colors.transparent,
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
          ),
          Container(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height/2,
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
          ),
          Container(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height/2,
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