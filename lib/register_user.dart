import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/rounded_button.dart';
import 'model/Drummer.dart';

class RegisterUser extends StatefulWidget {
  String? name;
  String? email;
  final ThemeManager themeManager;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  RegisterUser({
    Key? key,
    required this.name,
    required this.email,
    required this.themeManager,
    required this.observer,
    required this.analytics,
  }) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  var nameError = "";
  Drummer drummer = Drummer();
  int minInterests = 1;
  late String bandID;
  late DocumentReference bandsRef;
  late String imageURL;
  bool readToUpload = false;
  late String username;
  double uploadProgress = 0;
  File? pickedImage;
  double inputTextSize = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 60,),
                if (pickedImage == null)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: RoundedButton(
                      assetPath: "images/add-image.png",
                      height: 100,
                      color: Colors.white,
                      bgColor: Colors.transparent,
                      onPressed: () {
                        selectData();
                      },
                    ),
                  ),
                if (pickedImage != null)
                  GestureDetector(
                    onTap: () {
                      selectData();
                    },
                    child: Container(
                        alignment: Alignment.center,
                        child: Image.file(
                          pickedImage!,
                          height: 100,
                          alignment: Alignment.center,
                        )),
                  ),
                if (uploadProgress > 0 && uploadProgress < 1.0)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LinearProgressIndicator(
                      value: uploadProgress,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Please enter your details",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'alata',
                        fontWeight: FontWeight.normal),
                  ),
                ),
                if(widget.name==null)
                  Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Type your full name",
                        labelText: "Full Name",
                        hoverColor: Color(0xff008cff),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'alata',
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: 'alata',
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    // onSubmitted: (value) {
                    //   setState(() {
                    //     nameError = "";
                    //   });
                    //   FocusManager.instance.primaryFocus?.unfocus();
                    //   if (isValidDrummUsername(value)) usernameCheck(value.toLowerCase());
                    // },
                    onChanged: (value){
                      drummer.name = value;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Type a unique username",
                        labelText: "Username",
                        hoverColor: Color(0xff008cff),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'alata',
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: 'alata',
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    // onSubmitted: (value) {
                    //   setState(() {
                    //     nameError = "";
                    //   });
                    //   FocusManager.instance.primaryFocus?.unfocus();
                    //   if (isValidDrummUsername(value)) usernameCheck(value.toLowerCase());
                    // },
                    onChanged: (value){
                      drummer.username = value;
                    },
                  ),
                ),
                if(nameError.isNotEmpty)Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Text(
                    "$nameError",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Write something about yourself...",
                        labelText: "Bio",
                        hoverColor: Color(0xff008cff),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'alata',
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: 'alata',
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      drummer.bio = value;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "What do you do?",
                        labelText: "Profession",
                        hoverColor: Color(0xff008cff),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'alata',
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: 'alata',
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      drummer.jobTitle = value;
                      print(drummer.jobTitle );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Where do you work?",
                        labelText: "Organisation",
                        hoverColor: Color(0xff008cff),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'alata',
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: 'alata',
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      drummer.organisation = value;
                    },
                  ),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                    ),
                    child:  Text((uploadProgress == 0 || uploadProgress == 1)? "Continue":"Uploading Profile Pic...",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontFamily: "alata"),),
                  ),
                  onTap: (){
                    if(uploadProgress == 0 || uploadProgress == 1) {
                      if(readToUpload) {
                        if (isValidDrummUsername(
                            drummer.username ?? "")) usernameCheck(
                            drummer.username ?? "");
                      }
                      else{
                        AnimatedSnackBar.material(
                          'Please Upload the image',
                          type: AnimatedSnackBarType.error,
                        ).show(context);
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  void usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collectionGroup("users")
        .where("username", isEqualTo: username)
        .get();
    if (result.docs.isEmpty) {
      saveUserDetails();
    } else {
      debugPrint("Username already exists");
      setState(() {
        nameError = "Username already exists";
      });
    }
  }

  void selectData() {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${FirebaseAuth.instance.currentUser?.uid}.jpg');
    uploadPicture(
        storageReference,
        (double progress) {
          // Handle progress updates here
          print('Upload progress: $progress');
          setState(() {
            uploadProgress = progress;
          });
        },
        (String imageUrl) {
          print("Uploaded Image: ${imageUrl}");
          imageURL = imageUrl;
          drummer.imageUrl = imageUrl;
          setState(() {
            readToUpload = true;
          });

        },
        19,
        19,
        (File? image) {
          setState(() {
            pickedImage = image;
          });
        });
  }

  bool isValidDrummUsername(String username) {
    // Username must not be empty and must not exceed 30 characters
    if (username.isEmpty || username.length > 30 || username.length < 3) {
      debugPrint(
          "Username must not be less than 3 and must not exceed 30 characters");
      setState(() {
        nameError =
            "Username must not be less than 3 and must not exceed 30 characters";
      });
      return false;
    }

    // Username must only contain letters, numbers, periods, and underscores
    final validCharacters = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!validCharacters.hasMatch(username)) {
      debugPrint(
          "Username must only contain letters, numbers, periods, and underscores");
      setState(() {
        nameError =
            "Username must only contain letters, numbers, periods, and underscores";
      });
      return false;
    }

    // Username must not start with a period or underscore
    final startsWithPeriodOrUnderscore = RegExp(r'^[._]');
    if (startsWithPeriodOrUnderscore.hasMatch(username)) {
      debugPrint("Username must not start with a period or underscore");
      setState(() {
        nameError = "Username must not start with a period or underscore";
      });
      return false;
    }

    // Username must not end with a period or underscore
    final endsWithPeriodOrUnderscore = RegExp(r'[._]$');
    if (endsWithPeriodOrUnderscore.hasMatch(username)) {
      return false;
    }

    return true;
  }

  void saveUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;

    if(drummer.name==null&&widget.name==null){
      AnimatedSnackBar.material(
        'Fill in your name',
        type: AnimatedSnackBarType.error,
      ).show(context);
      return;
    }


    if(widget.name!=null) {
      drummer.name = widget.name;
    }
    drummer.email = widget.email;
    drummer.uid = uid;
    drummer.rid = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    drummer.badges = 0;
    drummer.speaking = false;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(drummer.toJson(), SetOptions(merge: true));

   // _checkOnboardingStatus(drummer.username??"");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => InterestsPage(
              themeManager: widget.themeManager,
              analytics: widget.analytics,
              observer: widget.observer,
            )));

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void _checkOnboardingStatus(String userName) async {
    bool _isOnboarded = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", userName);
    //prefs.remove('isOnboarded');
    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
    setState(() {
      _isOnboarded = isOnboarded;
    });

    if (_isOnboarded) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LauncherPage(
                    themeManager: widget.themeManager,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )));
    } else {
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
