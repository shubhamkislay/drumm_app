import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class EditBand extends StatefulWidget {
  Band band;
  @override
  EditBandState createState() => EditBandState();

  EditBand({super.key,
    required this.band,
  });
}

class EditBandState extends State<EditBand> {
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
  List selectedHooks = [];
  bool newSelected = false;

  List hookList = [];


  @override
  Widget build(BuildContext context) {
    TextEditingController descriptionTextController= TextEditingController(
        text: band.description
    );
    TextEditingController nameTextController= TextEditingController(
        text: band.name
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.maxFinite,
              child: const Text(
                'Edit your Band',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: APP_FONT_MEDIUM),
              ),
            ),
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
                      imageUrl: widget.band.url ?? "",),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.file(
                        pickedImage!,
                        height: 150,
                        alignment: Alignment.center,
                      ),
                    )),
              ),
            if (uploadProgress > 0 && uploadProgress < 1.0)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: LinearProgressIndicator(
                  value: uploadProgress,
                ),
              ),
            const SizedBox(
              height: 4,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Add hooks",
                style: TextStyle(fontSize: 18, fontFamily: APP_FONT_MEDIUM),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Hooks let your band pull news articles based on the category, which you can use to drumm with your band members",
                style: TextStyle(
                    fontSize: 10,
                    fontFamily: APP_FONT_MEDIUM,
                    color: Colors.white54),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.spaceBetween,
                spacing: 4,
                alignment: WrapAlignment.spaceBetween,
                children: hookList
                    .map(
                      (hook) => GestureDetector(
                        onTap: () {
                          List tempHooks = selectedHooks;
                          if (tempHooks.contains(hook)) {
                            tempHooks.remove(hook);
                          } else {
                            tempHooks.add(hook);
                          }

                          setState(() {
                            selectedHooks = tempHooks;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            color: selectedHooks.contains(hook)
                                ? Colors.white
                                : Colors.grey.shade900,
                            border: Border.all(
                                color: Colors.grey.shade800, width: 1.25),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            hook,
                            style: TextStyle(
                                color: selectedHooks.contains(hook)
                                    ? Colors.black
                                    : Colors.white,
                                fontFamily: APP_FONT_MEDIUM),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  band.name = val;
                },
                maxLines: 1,
                minLines: 1,
                cursorColor: Colors.white,
                controller: nameTextController,
                decoration: InputDecoration(
                  hintText: "Enter Band Name...",
                  labelText: "Band Name",
                  hoverColor: Colors.white,
                  iconColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.white12,
                        width: 1,
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  band.description = val;
                },
                maxLines: 10,
                minLines: 10,
                keyboardType: TextInputType.text,
                controller: descriptionTextController,
                decoration: InputDecoration(
                  hintText: "Enter Band description...",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.white12,
                      width: 1,
                    ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.black, fontFamily: APP_FONT_MEDIUM),
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
    bandsRef = FirebaseFirestore.instance.collection("bands").doc();
    getHooks();

    setState(() {
      selectedHooks = widget.band.hooks??[];
      band = widget.band;
    });
    super.initState();
  }

  void saveBand(BuildContext context) async {


    band.hooks = selectedHooks;

    await FirebaseFirestore.instance
        .collection("bands")
        .doc(band.bandId)
        .set(band.toJson(), SetOptions(merge: true));

    Navigator.pop(context);
  }

  void selectData() {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('$bandID.jpg');
    uploadPicture(
        storageReference,
        (double progress) {

          // Handle progress updates here
          setState(() {
            uploadProgress = progress;
            newSelected = true;
          });
        },
        (String imageUrl) {
          //print("Uploaded Image: ${imageUrl}");
          imageURL =
              "$imageUrl&lastupdated=${Timestamp.now().microsecondsSinceEpoch.toString()}";
          band.url = imageURL;
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
    if (readToUpload || !newSelected) {
      String bandName = band.name?.toLowerCase() ?? "";
      String bandDescription = band.description?.toLowerCase() ?? "";
      if (bandName.length < 3 || bandName.length > 30) {
        setState(() {
          AnimatedSnackBar.material(
            'Band name characters should in the range 3-30',
            type: AnimatedSnackBarType.info,
          ).show(context);
        });

      } else if (bandDescription.length < 10 || bandDescription.length > 1000) {
        setState(() {
          AnimatedSnackBar.material(
            'Band description characters should in the range 30-1000. It is currently of size ${bandDescription.length}',
            type: AnimatedSnackBarType.info,
          ).show(context);
        });

      } else {
        saveBand(context);
      }
    } else {
      setState(() {
        AnimatedSnackBar.material(
          'Please Upload the image',
          type: AnimatedSnackBarType.info,
        ).show(context);
      });

    }
  }


  void getHooks() async {
    List<String> bandHooks = await FirebaseDBOperations.getBandHooks();
    setState(() {
      hookList = bandHooks;
    });
  }
}
