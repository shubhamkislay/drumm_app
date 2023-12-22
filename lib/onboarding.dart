import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:drumm_app/LoginPage.dart';
import 'package:drumm_app/login_screen.dart';
import 'package:drumm_app/main.dart';
import 'package:drumm_app/policy_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:lottie/lottie.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/register_user.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'custom/transparent_slider.dart';
import 'model/band.dart';

class OnBoarding extends StatefulWidget {
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  const OnBoarding({
    Key? key,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);
  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  bool _isOnboarded = false;
  String actionState = "Continue";
  @override
  Widget build(BuildContext context) {
    double textSize = 28;
    double marginHeight = 200;
    Color offText = Colors.white.withOpacity(0.6);

    return Scaffold(
      backgroundColor: Colors.black,
      body: TransparentSlider(
        headerBackgroundColor: Colors.black,
        controllerColor: Colors.white,
        finishButtonText: actionState,
        pageBackgroundColor: Colors.black,
        centerBackground: true,
        onFinish: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                    themeManager: widget.themeManager,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )),
                  (_) => false);
        },
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
        finishButtonTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: "alata",
            fontWeight: FontWeight.bold,
            fontSize: 16),
        skipTextButton: Text(
          'Skip',
          style: TextStyle(color: Colors.white),
        ),
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
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Discover ',
                    style: TextStyle(
                        fontFamily: "alata",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Breaking ',
                        style: TextStyle(
                            fontFamily: "sans",
                            color: offText,
                            fontWeight: FontWeight.normal,
                            fontSize: textSize),
                      ),
                      TextSpan(
                        text: 'News',
                        style: TextStyle(
                            fontFamily: "sans",
                            color: offText,
                            fontWeight: FontWeight.normal,
                            fontSize: textSize),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Drumm',
                    style: TextStyle(
                        fontFamily: "alata",
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
                            fontFamily: "sans",
                            fontStyle: FontStyle.normal,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Join ',
                    style: TextStyle(
                        fontFamily: "sans", color: offText, fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Bands',
                          style: TextStyle(
                            fontFamily: "alata",
                            fontSize: textSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                          text: ' of Shared Passions',
                          style: TextStyle(
                            color: offText,
                            fontFamily: "sans",
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Let\'s ',
                    style: TextStyle(
                        color: offText, fontFamily: "sans", fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Drumm!',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "alata",
                            fontWeight: FontWeight.bold,
                            fontSize: textSize,
                          )),
                    ],
                  ),
                ),
                //PolicyTextWidget(),
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
