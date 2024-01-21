import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:drumm_app/policy_text.dart';
import 'package:drumm_app/register_user.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'InterestPage.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'main.dart';
import 'model/band.dart';

class LoginPage extends StatefulWidget {
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  const LoginPage({
    Key? key,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isOnboarded = false;
  bool signingIn = false;
  String apple = "Continue with Apple";
  String google = "Continue with Google";
  String signingIN = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
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
          ),
          if(signingIN != "Google" )GestureDetector(
            onTap: (){
              if(signingIN=="")
                signInWithApple();
              setState(() {
                signingIn = true;
                signingIN = "Apple";
                apple = "Signing in with Apple";
              });
            },
            child: Container(
              padding: EdgeInsets.all(20),
              margin:  EdgeInsets.symmetric(horizontal: 32),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade900, width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${apple}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: APP_FONT_MEDIUM
                    ),
                  ),
                  Icon(Icons.navigate_next_rounded,color: Colors.white,)
                ],
              ),
            ),
          ),
          SizedBox(height: 12,),
          if(signingIN != "Apple" ) GestureDetector(
            onTap: (){
              if(signingIN=="")
                signInWithGoogle();
              setState(() {
                signingIn = true;
                signingIN = "Google";
                google = "Signing in with Google";
              });

            },
            child: Container(
              padding: EdgeInsets.all(20),
              margin:  EdgeInsets.symmetric(horizontal: 32),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade900, width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${google}",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                        fontFamily: APP_FONT_MEDIUM,
                    ),
                  ),
                  Icon(Icons.navigate_next_rounded,color: Colors.black,)
                ],
              ),
            ),
          ),
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: PolicyTextWidget(),
          ),
          SizedBox(height: 100,),
        ],
      ),
    );
  }

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
    } catch (e) {
      print("Exception returned ${e.toString()}");
      setState(() {
        signingIn = false;
        signingIN = "";
        google = "Continue with Google";
      });
      return;
    }

    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      if (value.credential != null)
        checkIfUserExists(value,"google");
      else{
        setState(() {
          signingIn = false;
          signingIN = "";
          google = "Continue with Google";
        });
      }

    });
    // signin.then((value) => {checkIfUserExists(value)});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    var appleCredential;
    // Request credential for the currently signed in Apple account.
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          //AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
    } catch (e) {
      print("Exception returned ${e.toString()}");
      setState(() {
        signingIn = false;
        signingIN = "";
        apple = "Continue with Apple";
      });
      return;
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    final appleOauthProvider = OAuthProvider(
      "apple.com",
    );

    // appleOauthProvider.setScopes([
    //   'email',
    //   'name',
    // ]);

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = appleOauthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    FirebaseAuth.instance.signInWithCredential(oauthCredential).then((value) {
      if (value.credential != null) {
        checkIfUserExistsApple(value, "apple",appleCredential);
      }
      else
        setState(() {
          signingIn = false;
          signingIN = "";
          apple = "Continue with Apple";
        });
    });
    // signin.then((value) => {checkIfUserExists(value)});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void checkIfUserExists(UserCredential userCredential,String authProvider) async {
    SharedPreferences authPref = await SharedPreferences.getInstance();
    authPref.setString("authProvider", authProvider);
    authPref.commit();
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;
    final data =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();




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

  void checkIfUserExistsApple(UserCredential userCredential,String authProvider, dynamic appleCredential) async {
    SharedPreferences authPref = await SharedPreferences.getInstance();
    authPref.setString("authProvider", authProvider);
    authPref.commit();
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;
    final data =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // if (userCredential.user?.displayName == null ||
    //     (userCredential.user?.displayName != null && userCredential.user!.displayName!.isEmpty)) {
    //
    //
    //   final fixDisplayNameFromApple = [
    //     appleCredential.givenName ?? '',
    //     appleCredential.familyName ?? '',
    //   ].join(' ').trim();
    //   print("fixDisplayNameFromApple : ${fixDisplayNameFromApple}");
    //   if (FirebaseAuth.instance.currentUser?.displayName == null ||
    //       (FirebaseAuth.instance.currentUser?.displayName != null && FirebaseAuth.instance.currentUser!.displayName!.isEmpty)) {
    //     await userCredential.user?.updateDisplayName(fixDisplayNameFromApple);
    //     await userCredential.user?.reload();
    //   }
    //
    // }
    // if (userCredential.user?.email == null ||
    //     (userCredential.user?.email != null && userCredential.user!.email!.isEmpty)) {
    //   await userCredential.user?.updateEmail(appleCredential.email ?? '');
    // }

    //print("additionalUserInfo User name is : ${userCredential.additionalUserInfo?.username}");

     User? latestUser = FirebaseAuth.instance.currentUser;
    // print('Latest user is: ${latestUser?.displayName}');
    // print("userCredential User name is : ${userCredential.user?.displayName}");
    //print("providerData User name is : ${userCredential.user?.providerData.elementAt(0).displayName}");

    var fixDisplayNameFromApple = "";

    try {
      fixDisplayNameFromApple = [
        appleCredential.givenName ?? '',
        appleCredential.familyName ?? '',
      ].join(' ').trim();
    }catch(e){
      print("fixDisplayNameFromApple is null");
    }

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
                    name: fixDisplayNameFromApple,
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
                  name: latestUser?.displayName,
                  email: userCredential.user?.email)));
    }
  }

  void _checkOnboardingStatus(String uname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", uname);
    //prefs.remove('isOnboarded');
    List<Band> bandList = await FirebaseDBOperations.getBandByUser();

    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
    if (bandList.length > 0) {
      isOnboarded = true;
      await prefs.setBool('isOnboarded', true);
      _isOnboarded = isOnboarded;
    }
    setState(() {
      _isOnboarded = isOnboarded;
    });

    if ((FirebaseAuth.instance.currentUser != null))
      FirebaseDBOperations.subscribeToUserBands();

    if (_isOnboarded) {
      print("Calling launcer Page from onboarding page");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyApp()));
    } else {
      print("Calling interest Page from onboarding page");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InterestsPage(
                themeManager: widget.themeManager,
                analytics: widget.analytics,
                observer: widget.observer,
              )));
    }
  }
}
