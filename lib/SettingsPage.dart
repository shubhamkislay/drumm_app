import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drumm_app/main.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom/helper/connect_channel.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Function to handle logout
  void _logout() {
    // Add your logout logic here
    if (ConnectToChannel.engineInitialized) ConnectToChannel.disposeEngine();

    FirebaseAuth.instance.signOut().then((value) {
      removedPreferences();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => MyApp()), (_) => false);
    });
    print('Logged out'); // You can replace this with your actual logout logic
  }

  void deleteUser() {
    try {
      if (ConnectToChannel.engineInitialized) ConnectToChannel.disposeEngine();
    } catch (e) {}

    FirebaseAuth.instance.currentUser?.delete().then((value) {
      removedPreferences();
      FirebaseAuth.instance
          .signOut()
          .then((value) => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => MyApp()), (_) => false))
          .onError((error, stackTrace) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => MyApp()), (_) => false);
      });
    }).onError((error, stackTrace) {
      print("The user cannot be deleted because ${error}");
      print("Reauthenticating");
      reauthenticate();
    });
  }

  // Function to open a web page
  Future<void> _openWebPage(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(fontFamily: APP_FONT_MEDIUM, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Privacy Policy',style: TextStyle(
                    fontFamily: APP_FONT_MEDIUM,
                  ),),
                  onTap: () {
                    _openWebPage(
                        'https://www.termsfeed.com/live/6bb937e0-0e2f-4d01-8257-5983452d2019');
                  },
                ),
                ListTile(
                  title: Text('Terms and Conditions',
                  style: TextStyle(
                    fontFamily: APP_FONT_MEDIUM,
                  ),),
                  onTap: () {
                    _openWebPage(
                        'https://getdrumm.blogspot.com/2023/12/terms-and-conditions-for-drumm.html');
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _logout();
            },
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: APP_FONT_MEDIUM),
                  ),
                  Icon(
                    Icons.navigate_next_rounded,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              // deleteUser();

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(0.0)),
                      child: AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        title: Text(
                            "Are you sure you want to delete your account?"),
                        actions: [
                          GestureDetector(
                            onTap: () {
                              deleteUser();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.25), width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delete Account",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: APP_FONT_MEDIUM),
                  ),
                  Icon(
                    Icons.navigate_next_rounded,
                    color: Colors.red,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }

  void reauthenticate() async {
    SharedPreferences authPref = await SharedPreferences.getInstance();
    String authProvider = authPref.getString("authProvider") ?? "apple";

    if (authProvider == "apple")
      signInWithApple();
    else if (authProvider == "google")
      signInWithGoogle();
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
              child: AlertDialog(
                backgroundColor: Colors.grey.shade900,
                title: Text("Please sign in again to continue with account deletion. Select one of the following to continue"),
                actions: [
                  GestureDetector(
                    onTap: () {
                      signInWithGoogle();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "Google",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      signInWithApple();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "Apple",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
    } catch (e) {}

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(oauthCredential)
        .then((value) {
      deleteUser();
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
      return;
    }

    FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(credential)
        .then((value) {
      deleteUser();
    });
    // signin.then((value) => {checkIfUserExists(value)});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsPage(),
  ));
}
