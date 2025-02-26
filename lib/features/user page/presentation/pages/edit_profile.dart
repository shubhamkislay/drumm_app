import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/data/model/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/SearchDesignationsDropdown.dart';
import 'package:drumm_app/custom/SearchProfessionDropdown.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/profession.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
class EditProfile extends StatefulWidget {
  DrummerEntity? drummer;
  EditProfile({
    Key? key,
    required this.drummer,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var nameError = "";
  DrummerEntity drummer = DrummerEntity();
  int minInterests = 1;
  late String bandID;
  late DocumentReference bandsRef;
  late String imageURL;
  bool readToUpload = true;
  late String username;
  double uploadProgress = 0;
  File? pickedImage;
  double inputTextSize = 18;
  bool saving = false;

  List<Profession> professions = [];

  Profession selectedProfession = Profession();

  String selectedDesignation = "";

  Widget selectedItem = Container();

  Widget moreAbout = Container();
  bool isLight = false;

  TextEditingController textEditingController = TextEditingController();

  String moreAboutTxt = "";

  Profession initialProfession = Profession();

  String initialDesignation = "";
  String originalDesignation = "";
  String originalDepartmentName = "";
  String? newImageUrl = "";
  String? newJobTitle = "";
  String? newOccupation = "";

  String? newBio = "";

  @override
  Widget build(BuildContext context) {
    newOccupation = drummer.occupation;
    newImageUrl = drummer.imageUrl;
    newJobTitle = drummer.jobTitle;
    newBio = drummer.bio;
    isLight= !DrummTheme.isDarkMode(context);

    return Scaffold(
      backgroundColor: DrummTheme.primaryItemBackground(context),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SafeArea(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 28,
                      color: DrummTheme.primaryTextColor(context),
                    ),
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (pickedImage == null)
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(32.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: GestureDetector(
                          onTap: () {
                            selectData();
                          },
                          child: CachedNetworkImage(
                            imageUrl: drummer.imageUrl ?? "",height: 300,width: 300,
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
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    margin: const EdgeInsets.all(32.0),
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.edit_rounded, size: 64,color: Colors.white,),
                  )

                ],
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
                        isLight: !DrummTheme.isDarkMode(context),
                        initialProfession: initialProfession,
                        colorTheme: DrummTheme.primaryItemColor(context),
                        professionSelectedCallback: (Profession profession) {
                          setState(() {
                            selectedProfession = profession;
                            newOccupation = profession.departmentName;
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
                      color: DrummTheme.primaryItemColor(context)),
                  child: (!saving)
                      ? Text(
                          (uploadProgress == 0 || uploadProgress == 1)
                              ? "Save"
                              : "Uploading Profile Pic...",
                          style: TextStyle(color: DrummTheme.primaryTextColor(context)),
                        )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 22,
                              width: 22,
                              child: CircularProgressIndicator()),
                          SizedBox(width: 12,),
                          Text("Saving...",
                            style: TextStyle(color: DrummTheme.primaryTextColor(context)),
                          ),
                        ],
                      ),
                ),
                onTap: () {
                  if (!saving) {
                    setState(() {
                      if (uploadProgress == 0 || uploadProgress == 1) {
                        if (readToUpload) {
                          saveUserDetails();
                          saving = true;
                        } else {
                          AnimatedSnackBar.material(
                            'Please Upload the image',
                            type: AnimatedSnackBarType.error,
                          ).show(context);
                        }
                      }
                    });
                  }
                },
              )
            ],
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
          //drummer.imageUrl = imageURL;
          newImageUrl = imageUrl;
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
          originalDepartmentName = widget.drummer!.occupation! ?? "";
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

    DrummerModel drummerModel = DrummerModel(
      jobTitle: newJobTitle,
      bio: newBio,
      imageUrl: newImageUrl,
      occupation: newOccupation,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(drummerModel.toJson(), SetOptions(merge: true));

    FirebaseDBOperations.unsubscribeToYourExpertise(
        originalDepartmentName ?? "", originalDesignation ?? "");

    FirebaseDBOperations.subscribeToYourExpertise(
        widget.drummer?.occupation ?? "", widget.drummer?.jobTitle ?? "");

    // _checkOnboardingStatus(drummer.username??"");

    setState(() {
      saving = false;
    });
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
                isLight: isLight,
                designations:
                    initialProfession.designations ?? ["$initialDesignation"],
                designationsSelectedCallback: (String designation) {
                  setState(() {
                    selectedDesignation = designation;
                    //drummer.jobTitle = designation;
                    newJobTitle = designation;
                    setMoreAboutWidget();
                  });
                },
              )
            : SearchDesignationDropdown(
                designations: selectedProfession.designations ?? [],
                isLight: isLight,
                designationsSelectedCallback: (String designation) {
                  setState(() {
                    selectedDesignation = designation;
                    //drummer.jobTitle = designation;
                    newJobTitle = designation;
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
          fillColor: (isLight)?DrummTheme.primaryLightItemColor:DrummTheme.primaryDarkItemColor,
          hintText: "Tell us more about your role (optional)",
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (value) {
          moreAboutTxt = value;
          newBio = moreAboutTxt;
        },
      );
    });
  }
}
