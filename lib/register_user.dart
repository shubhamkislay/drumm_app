import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/professionDetailsPage.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  var bioTxt = TextEditingController();
  var orgTxt = TextEditingController();
  var professionTxt = TextEditingController();
  var nameTxt = TextEditingController();
  var usernameTxt = TextEditingController();

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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Account Creation",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: APP_FONT_MEDIUM,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                if (pickedImage == null)
                   (drummer.imageUrl != null)?
                       CachedNetworkImage(
                         imageUrl: modifyImageUrl(drummer.imageUrl ?? "", "300x300"),
                        height: 150,
                         width: 150,
                       )
                       : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
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
                if (pickedImage == null&&drummer.imageUrl==null)
                Text(
                  "Add a profile picture",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: APP_FONT_MEDIUM,
                      fontWeight: FontWeight.normal),
                ),
                if (uploadProgress > 0 && uploadProgress < 1.0)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LinearProgressIndicator(
                      value: uploadProgress,
                    ),
                  ),
                SizedBox(height: 12,),
                if(widget.name!=null&&!widget.name!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 24),
                    child: Text("Hey ${widget.name}, please enter the following details!",style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: APP_FONT_MEDIUM,
                        fontWeight: FontWeight.normal),),
                  ),
                if(widget.name==null || widget.name!=null&&widget.name!.isEmpty)
                  Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: nameTxt,
                    decoration: InputDecoration(
                        hintText: "Type your full name",
                        labelText: "Full Name",
                        hoverColor: Colors.white,
                        hintStyle: TextStyle(
                          color: Colors.white24,
                          fontFamily: APP_FONT_MEDIUM,
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: APP_FONT_MEDIUM,
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value){
                      drummer.name = value;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: usernameTxt,
                    decoration: InputDecoration(
                        hintText: "Type a unique username",
                        labelText: "Username",
                        hoverColor: Colors.white,
                        hintStyle: TextStyle(
                          color: Colors.white24,
                          fontFamily: APP_FONT_MEDIUM,
                        )),
                    style: TextStyle(
                      fontSize: inputTextSize,
                      fontFamily: APP_FONT_MEDIUM,
                      color: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
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
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.symmetric(horizontal: 24,vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white
                    ),
                    child:  Text((uploadProgress == 0 || uploadProgress == 1)? "Continue":"Uploading Profile Pic...",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontFamily: APP_FONT_MEDIUM),),
                  ),
                  onTap: (){
                    if(uploadProgress == 0 || uploadProgress == 1) {
                      if(readToUpload || drummer.imageUrl!=null) {
                        if (isValidDrummUsername(
                            drummer.username ?? "")) usernameCheck(
                            drummer.username ?? "");
                      }
                      else{
                        AnimatedSnackBar.material(
                          'Please add a profile picture to continue',
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
    getDrummer();

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
            builder: (context) => ProfessionDetailsPage(
            )));

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void getDrummer() async{
    Drummer fetchDrummer = await FirebaseDBOperations.getDrummer(FirebaseAuth.instance.currentUser?.uid??"");

    setState(() {
      drummer = fetchDrummer;
      bioTxt.text = drummer.bio!;
      orgTxt.text = drummer.organisation!;
      professionTxt.text = drummer.jobTitle!;
      nameTxt.text = drummer.name!;
      widget.name = drummer.username!;
      usernameTxt.text = drummer.username!;
    });
  }
}
