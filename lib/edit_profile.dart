import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/rounded_button.dart';
import 'model/Drummer.dart';

class EditProfile extends StatefulWidget {
  Drummer? drummer;
  EditProfile({
    Key? key,
    required this.drummer,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var nameError = "";
  Drummer drummer = Drummer();
  int minInterests = 1;
  late String bandID;
  late DocumentReference bandsRef;
  late String imageURL;
  bool readToUpload = true;
  late String username;
  double uploadProgress = 0;
  File? pickedImage;
  double inputTextSize = 18;


  @override
  Widget build(BuildContext context) {
    TextEditingController bioTextController= TextEditingController(
        text: drummer.bio
    );
    TextEditingController professionTextController= TextEditingController(
        text: drummer.jobTitle
    );
    TextEditingController orgTextController= TextEditingController(
        text: drummer.organisation
    );

    return Container(
      color: Colors.black,
      child: SafeArea(
        top: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (pickedImage == null)
                  Container(
                    padding:  const EdgeInsets.all(32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GestureDetector(
                        onTap: (){
                          selectData();
                        },
                        child: CachedNetworkImage(
                            imageUrl: drummer.imageUrl ?? "",),
                      ),
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
                          height: 200,
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
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                      margin: EdgeInsets.symmetric(horizontal: 24),

                      decoration: BoxDecoration(
                          color: COLOR_PRIMARY_DARK,
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Write something about yourself...",
                            labelText: "Bio",
                            hoverColor: Color(0xff008cff),
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontFamily: APP_FONT_MEDIUM,
                            )),
                        style: TextStyle(
                          fontSize: inputTextSize,
                          fontFamily: APP_FONT_MEDIUM,
                          color: Colors.white,
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          drummer.bio = value;
                        },
                        controller: bioTextController,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                      margin: EdgeInsets.symmetric(horizontal: 24),

                      decoration: BoxDecoration(
                          color: COLOR_PRIMARY_DARK,
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "What do you do?",
                            labelText: "Profession",
                            hoverColor: Color(0xff008cff),
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontFamily: APP_FONT_MEDIUM,
                            )),
                        style: TextStyle(
                          fontSize: inputTextSize,
                          fontFamily: APP_FONT_MEDIUM,
                          color: Colors.white,
                        ),
                        textInputAction: TextInputAction.done,
                        controller: professionTextController,
                        onChanged: (value) {
                          drummer.jobTitle = value;
                          print(drummer.jobTitle);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                      margin: EdgeInsets.symmetric(horizontal: 24),

                      decoration: BoxDecoration(
                          color: COLOR_PRIMARY_DARK,
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Where do you work?",
                            labelText: "Organisation",
                            hoverColor: Color(0xff008cff),
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontFamily: APP_FONT_MEDIUM,
                            )),
                        style: TextStyle(
                          fontSize: inputTextSize,
                          fontFamily: APP_FONT_MEDIUM,
                          color: Colors.white,
                        ),
                        textInputAction: TextInputAction.done,
                        controller: orgTextController,
                        onChanged: (value) {
                          drummer.organisation = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Text(
                      (uploadProgress == 0 || uploadProgress == 1)
                          ? "Save"
                          : "Uploading Profile Pic...",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (uploadProgress == 0 || uploadProgress == 1) {
                        if (readToUpload) {
                          saveUserDetails();
                        } else {
                          AnimatedSnackBar.material(
                            'Please Upload the image',
                            type: AnimatedSnackBarType.error,
                          ).show(context);
                        }
                      }
                    });
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
    drummer = widget.drummer!;
    super.initState();

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

  void saveUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(drummer.toJson(), SetOptions(merge: true));

    // _checkOnboardingStatus(drummer.username??"");
    Navigator.pop(context);

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}
