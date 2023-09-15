import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/register_user.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  const LoginScreen({
    Key? key,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isOnboarded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: Color(0xFF262626),
        child: Stack(children: [
          /**Drumm Logo**/
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 110, 24, 0),
            child: AnimatedOpacity(
              curve: Curves.elasticIn,
              opacity: 1.0, //currentDrummOpacity,
              duration: const Duration(milliseconds: 1000),
              child: Material(
                elevation: 1.0,
                //type: MaterialType.circle,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.transparent, width: 2.5),
                ),
                borderOnForeground: true,
                shadowColor: Color(0xffffff),
                color: Color(0xffffff),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 350,
                  child: Image.asset(
                    color: Color(0xD8181818), //Color(0x4a008cff),
                    width: 350,
                    "images/logo_background_white.png",
                    height: 350,
                  ),
                ),
              ), //const Image(
              //   height: 150,
              //   width: 150,
              //   image:
              //       AssetImage("images/logo_background_white.png"),
              // ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color(0xff008cff)),
                  ),
                  onPressed: () {
                    Future<UserCredential> signin = signInWithGoogle();
                    signin.then((value) => {checkIfUserExists(value)});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36.0, top: 24),
                    child: Text(
                      "Continue with Google",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Text(
              "Let's get started.",
              style: TextStyle(
                  fontSize: 54,
                  color: Colors.white,
                  fontFamily: 'alata',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
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
    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
    setState(() {
      _isOnboarded = isOnboarded;
    });

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
