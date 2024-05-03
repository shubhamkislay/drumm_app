import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/SearchDesignationsDropdown.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'InterestPage.dart';
import 'custom/ProfessionChipSelectionWidget.dart';
import 'custom/SearchProfessionDropdown.dart';
import 'model/Drummer.dart';
import 'model/band.dart';
import 'model/profession.dart';

class ProfessionDetailsPage extends StatefulWidget {
  Drummer? drummer;
   ProfessionDetailsPage({super.key, this.drummer});

  @override
  State<ProfessionDetailsPage> createState() => _ProfessionDetailsPageState();
}

class _ProfessionDetailsPageState extends State<ProfessionDetailsPage> {
  List<Profession> professions = [];
  Profession selectedProfession = Profession();
  String selectedDesignation = "";
  Widget selectedItem = Container();
  Widget moreAbout = Container();
  String moreAboutTxt = "";
  bool moveToInterestPage = true;
  TextEditingController textEditingController = TextEditingController();
  String currentDesignation = "";
  String currentDepartmentName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 0,),
                   if(false) Image.asset(
                      "images/verify.png",
                      width: 150,
                      height: 150,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    const Text(
                      "Select your Expertise",
                      style: TextStyle(fontSize: 26, fontFamily: APP_FONT_MEDIUM),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ProfessionChipSelectionWidget(
                      selectedCallback: (selectedDesign, selectedProfess) {

                        setState(() {
                          selectedProfession = selectedProfess;
                          widget.drummer?.occupation = selectedProfession.departmentName;
                          selectedDesignation = selectedDesign;
                          widget.drummer?.jobTitle = selectedDesignation;
                        });

                        saveUserDetails();
                      },
                    ),
                    if (professions.isNotEmpty &&false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SearchProfessionDropdown(
                          professions: professions,
                          professionSelectedCallback: (Profession profession) {
                            setState(() {
                              selectedProfession = profession;
                              widget.drummer?.occupation = profession.departmentName;
                              selectedDesignation = "";

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
                    if(false)  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: selectedItem
                      ),
                    SizedBox(
                      height: 12,
                    ),
                   if(false) Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: moreAbout
                    ),
                  ],
                ),
              ),
            ),
            if(selectedDesignation.isNotEmpty&&selectedProfession.departmentName!.isNotEmpty&&false)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  saveUserDetails();
                },
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(4),

                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfessions();
    getUserBands();
    if(widget.drummer==null){
      getDrummer();
    }
  }

  void getProfessions() async {
    List<Profession> fetchProfessions =
        await FirebaseDBOperations.getProfessions();

    setState(() {
      professions = fetchProfessions;
    });
  }

  void setWidget() async{

    Future.delayed(Duration(milliseconds: 100),(){
      setState(() {
        selectedItem = SearchDesignationDropdown(
          designations: selectedProfession.designations??[],
          designationsSelectedCallback: (String designation) {

            setState(() {
              selectedDesignation = designation;
              widget.drummer?.jobTitle = designation;
              setMoreAboutWidget();
            });
          },

        );
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
        onChanged: (value){
          moreAboutTxt = value;
          widget.drummer?.bio = moreAboutTxt;
        },
      );
    });
  }

  void getUserBands() async{

    List<Band> userBands = await FirebaseDBOperations.getBandByUser();
    if(userBands.isNotEmpty)
      moveToInterestPage = false;
  }

  void getDrummer() async{
    Drummer fetchDrummer = await FirebaseDBOperations.getDrummer(FirebaseAuth.instance.currentUser?.uid??"");
    setState(() {
      widget.drummer = fetchDrummer;
    });
  }
  void saveUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(widget.drummer!.toJson(), SetOptions(merge: true));

    FirebaseDBOperations.subscribeToYourExpertise(widget.drummer?.occupation??"",widget.drummer?.jobTitle??"");

    // _checkOnboardingStatus(drummer.username??"");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProfessionDetailsPage(
            )));

    if(moveToInterestPage) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InterestsPage()));
    }
    else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LauncherPage()));
    }

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}
