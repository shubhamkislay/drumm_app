import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    double textSize = 32;
    double marginHeight = 200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: OnBoardingSlider(
        headerBackgroundColor: Colors.black,
        controllerColor: Colors.white,
        finishButtonText: actionState,
        pageBackgroundColor: Colors.black,
        onFinish: (){
         // Future<UserCredential> signin =

          if(actionState == "Continue") {
            setState(() {
              actionState = "Signing in...";
            });
            signInWithGoogle();
          }
         // signin.then((value) => {checkIfUserExists(value)});
        },
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: (actionState == "Continue") ? Color(0xff008cff):Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
        skipTextButton: Text('Skip'),
        background: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: Lottie.asset('images/animation_news.json',height: 300,fit:BoxFit.contain ,width: double.maxFinite),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: Lottie.asset('images/animation_bands.json',height: 300,fit:BoxFit.contain ,width: double.maxFinite),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                child: Lottie.asset('images/animation_band.json',height: 300,fit:BoxFit.contain ,width: double.maxFinite),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: marginHeight,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Discover Breaking',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' News',
                        style: TextStyle(
                          color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: textSize+4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: marginHeight,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Drumm',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' and talk with Fellow Enthusiasts',
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: marginHeight,
                ),
                RichText(

                  text: TextSpan(
                    text: 'Join ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Bands',
                          style: TextStyle(
                              color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          )
                      ),
                      TextSpan(
                          text: ' of Shared Passions',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: marginHeight,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Let\'s ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: textSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Drumm!',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Future<UserCredential>
  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    // Create a new credential
    var credential;
    try {
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
    }catch(e){
      print("Exception returned ${e.toString()}");
      setState(() {
        actionState = "Continue";
      });
      return;
    }

    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      if(value.credential!=null)
        checkIfUserExists(value);
      else
        setState(() {
          actionState = "Continue";
        });
    });
   // signin.then((value) => {checkIfUserExists(value)});


    // Once signed in, return the UserCredential
   // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void checkIfUserExists(UserCredential userCredential) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    try {
      String uname = data['username'].toString();

      if (uname.isNotEmpty) {
        _checkOnboardingStatus(uname);
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterUser(
                    themeManager: widget.themeManager,
                    analytics: widget.analytics,
                    observer: widget.observer,
                    name: userCredential.user?.displayName,
                    email: userCredential.user?.email)));
      }
    } catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterUser(
                  themeManager: widget.themeManager,
                  analytics: widget.analytics,
                  observer: widget.observer,
                  name: userCredential.user?.displayName,
                  email: userCredential.user?.email)));
    }
  }

  void _checkOnboardingStatus(String uname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", uname);
    //prefs.remove('isOnboarded');
    List<Band> bandList = await FirebaseDBOperations.getBandByUser();

    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
    if(bandList.length>0) {
      isOnboarded = true;
      _isOnboarded = isOnboarded;
    }
    setState(() {
      _isOnboarded = isOnboarded;
    });

    if((FirebaseAuth.instance.currentUser != null))
      FirebaseDBOperations.subscribeToUserBands();

    if (_isOnboarded) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LauncherPage(
        themeManager: widget.themeManager,
        analytics: widget.analytics,
        observer: widget.observer,
      )));

    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => InterestsPage(
        themeManager: widget.themeManager,
        analytics: widget.analytics,
        observer: widget.observer,
      )));

    }
  }
}