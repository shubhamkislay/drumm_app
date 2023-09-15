import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:drumm_app/view_band.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/helper/image_uploader.dart';
import 'model/band.dart';

class CreateBand extends StatefulWidget {
  @override
  CreateBandState createState() => CreateBandState();
}

class CreateBandState extends State<CreateBand> {
  List<String> selectedInterests = [];

  int minInterests = 1;
  late String bandID;
  late DocumentReference bandsRef;
  late String imageURL;
  bool readToUpload = false;
  late String username;
  double uploadProgress = 0;
  File? pickedImage;
  Band band = Band();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 42, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              width: double.maxFinite,
              child: Text(
                'Create a Band',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                onTap: (){ selectData();},
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  band.name = val;
                },
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Enter Band Name...",
                  labelText: "Name",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  band.description = val;
                },
                maxLines: 10,
                minLines: 10,

                decoration: InputDecoration(
                  hintText: "Enter Band description...",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                validateData();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Create"),
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
    getPrefs();
    bandsRef = FirebaseFirestore.instance.collection("bands").doc();

    // Add a new document with an automatically generated push
    String pushId = bandsRef.id;
    bandID = pushId;
    band.bandId = bandID;
    super.initState();
  }

  void createBand(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isOnboarded', true);
    // await prefs.setStringList('interestList', interestList);
    band.foundedBy = getCurrentUserID();
    band.count = "1";
    band.visibility = "public";
    band.creationTime = Timestamp.now();

    FirebaseDBOperations.createBand(band).then((value) {
      if (value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BandDetailsPage(
              band: band,
            ),
          ),
        );
      }
    });
  }

  void selectData(){
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('$bandID.jpg');
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
          band.url = imageUrl;
          readToUpload = true;
        },
        19,
        19,
            (File? image) {
          setState(() {
            pickedImage = image;
          });
        });
  }

  void validateData() {
    if (readToUpload) {
      String bandName = band.name?.toLowerCase() ?? "";
      String bandDescription = band.description?.toLowerCase() ?? "";
      if (bandName.length < 3 || bandName.length > 30)
        AnimatedSnackBar.material(
          'Band name characters should in the range 3-30',
          type: AnimatedSnackBarType.info,
        ).show(context);
      else if (bandDescription.length < 10 || bandDescription.length > 300)
        AnimatedSnackBar.material(
          'Band description characters should in the range 30-300',
          type: AnimatedSnackBarType.info,
        ).show(context);
      else
        createBand(context);
    } else
      AnimatedSnackBar.material(
        'Please Upload the image',
        type: AnimatedSnackBarType.info,
      ).show(context);
  }

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> userInterests = prefs.getStringList('interestList')!;
    username = prefs.getString("username")!;
    // setState(() {
    //   selectedInterests = userInterests;
    // });
  }
}
