import 'package:blur/blur.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/background_final_button.dart';

import 'custom/transparent_slider.dart';

class TutorialScreen extends StatelessWidget {
  VoidCallback finishTutorial;
  TutorialScreen({required this.finishTutorial});

  @override
  Widget build(BuildContext context) {
    double textSize = 28;
    return Container(
        color: Colors.transparent,
        child: TransparentSlider(
          headerBackgroundColor: Colors.transparent,
          pageBackgroundColor: Colors.transparent,
          controllerColor: Colors.white,
          finishButtonText: "End tutorial",
          finishButtonTextStyle: TextStyle(
              color: Colors.black,
              fontFamily: APP_FONT_MEDIUM,
              fontWeight: FontWeight.bold),
          onFinish: () {
            finishTutorial();
          },
          finishButtonStyle: FinishButtonStyle(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(64.0),
              ),
            ),
          ),
          skipTextButton: Text(
            'Skip',
            style: TextStyle(color: Colors.white),
          ),
          background: [
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.75,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(8),
                child: Text(
                  "Welcome to Drumm!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: APP_FONT_MEDIUM,
                      fontSize: 32),
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.75,
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      border: Border.all(color: Colors.grey.shade800,width: 2.5)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade900,
                            spreadRadius: 2,
                            blurRadius: 4),
                      ],
                      gradient: LinearGradient(colors: [
                        Colors.orange,
                        Colors.red,
                        Colors.pinkAccent,
                      ]),
                    ),
                    child: Image.asset(
                      'images/google-earth.png',
                      height: 150,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),

                  ),
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.75,
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(124),
                      border: Border.all(color: Colors.grey.shade800,width: 2.5)),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(124),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade900,
                            spreadRadius: 2,
                            blurRadius: 4),
                      ],
                      gradient: LinearGradient(colors: [
                        Colors.indigo,
                        Colors.blue.shade700,
                        Colors.lightBlue,
                      ]),
                    ),
                    child: Image.asset(
                      'images/audio-waves.png',
                      height: 124,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),

                  ),
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.75,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "images/drumm_logo.png",
                  color: Colors.white,
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ],
          totalPage: 4,
          speed: 1.8,
          pageBodies: [
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Swipe',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: APP_FONT_MEDIUM,
                            fontSize: textSize),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Left',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_MEDIUM,
                                fontSize: textSize),
                          ),
                          TextSpan(
                            text:
                            '\nto discover and explore the news cards',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.normal,
                                fontFamily: APP_FONT_MEDIUM,
                                fontSize: textSize - 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Swipe',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: APP_FONT_MEDIUM,
                          fontSize: textSize),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' Right',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: APP_FONT_MEDIUM,
                              fontSize: textSize),
                        ),
                        TextSpan(
                          text:
                          '\non the news card to start drumming',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: APP_FONT_MEDIUM,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              fontSize: textSize - 10),
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
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Tap the',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: APP_FONT_MEDIUM,
                            fontSize: textSize),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' icon',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_MEDIUM,
                                fontSize: textSize),
                          ),
                          TextSpan(
                            text: '\nto checkout the live drumms',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.normal,
                                fontFamily: APP_FONT_MEDIUM,
                                fontSize: textSize - 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ))
        .frosted(
        blur: 10, frostColor: Colors.black.withOpacity(0.75));
  }
}
