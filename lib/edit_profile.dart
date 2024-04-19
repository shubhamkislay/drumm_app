import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/SearchDesignationsDropdown.dart';
import 'custom/SearchProfessionDropdown.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'custom/rounded_button.dart';
import 'model/Drummer.dart';
import 'model/profession.dart';

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

  List<Profession> professions = [];

  Profession selectedProfession = Profession();

  String selectedDesignation = "";

  Widget selectedItem = Container();

  Widget moreAbout = Container();

  TextEditingController textEditingController = TextEditingController();

  String moreAboutTxt = "";

  Profession initialProfession = Profession();

  String initialDesignation = "";
  String originalDesignation = "";
  String originalDepartmentName = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController bioTextController =
        TextEditingController(text: drummer.bio);
    TextEditingController professionTextController =
        TextEditingController(text: drummer.jobTitle);
    TextEditingController orgTextController =
        TextEditingController(text: drummer.organisation);

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
                    padding: const EdgeInsets.all(32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GestureDetector(
                        onTap: () {
                          selectData();
                        },
                        child: CachedNetworkImage(
                          imageUrl: drummer.imageUrl ?? "",
                        ),
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
                    if (professions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SearchProfessionDropdown(
                          professions: professions,
                          initialProfession: initialProfession,
                          professionSelectedCallback: (Profession profession) {
                            setState(() {
                              selectedProfession = profession;
                              drummer.occupation = profession.departmentName;
                              selectedDesignation = "";
                              initialDesignation = "";

                              selectedItem = Container();
                              moreAbout = Container();
                              textEditingController.clear();
                              moreAboutTxt = "";
                              setWidget();
                            });
                          },
                        ),
                      ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: selectedItem),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: moreAbout),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
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
    getProfessions();
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
          print(
              "Uploaded Image: ${imageUrl}&lastupdated=${Timestamp.now().microsecondsSinceEpoch.toString()}");
          imageURL =
              "$imageUrl&lastupdated=${Timestamp.now().microsecondsSinceEpoch.toString()}";
          drummer.imageUrl = imageURL;
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

  void getProfessions() async {
    List<Profession> fetchProfessions =
        await FirebaseDBOperations.getProfessions();
    for (Profession profession in fetchProfessions) {
      if (drummer.occupation == profession.departmentName) {
        setState(() {
          initialProfession = profession;
          initialDesignation = widget.drummer!.jobTitle ?? "";
          originalDesignation = widget.drummer!.jobTitle ?? "";
          originalDepartmentName = widget.drummer!.occupation!??"";
          textEditingController.text = widget.drummer!.bio ?? "";
        });
        break;
      }
    }
    setState(() {
      professions = fetchProfessions;
      setWidget();
      setMoreAboutWidget();
    });
  }

  void saveUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(drummer.toJson(), SetOptions(merge: true));

    FirebaseDBOperations.unsubscribeToYourExpertise(originalDepartmentName??"",originalDesignation??"");

    FirebaseDBOperations.subscribeToYourExpertise(widget.drummer?.occupation??"",widget.drummer?.jobTitle??"");

    // _checkOnboardingStatus(drummer.username??"");
    Navigator.pop(context);

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void setWidget() async {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        selectedItem = (initialDesignation.length > 0)
            ? SearchDesignationDropdown(
                initialDesignation: initialDesignation,
                designations:
                    initialProfession.designations ?? ["$initialDesignation"],
                designationsSelectedCallback: (String designation) {
                  setState(() {
                    selectedDesignation = designation;
                    drummer.jobTitle = designation;
                    setMoreAboutWidget();
                  });
                },
              )
            : SearchDesignationDropdown(
                designations: selectedProfession.designations ?? [],
                designationsSelectedCallback: (String designation) {
                  setState(() {
                    selectedDesignation = designation;
                    drummer.jobTitle = designation;
                    setMoreAboutWidget();
                  });
                },
              );

        setMoreAboutWidget();
      });
    });
  }

  void setMoreAboutWidget() {
    print("Setting more about");

    setState(() {
      moreAbout = TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade900,
          hintText: "Tell us more about your role (optional)",
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (value) {
          moreAboutTxt = value;
          drummer.bio = moreAboutTxt;
        },
      );
    });
  }
}
