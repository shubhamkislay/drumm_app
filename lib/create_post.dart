import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/helper/image_uploader.dart';

class CreatePost extends StatefulWidget {
  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> {
  List<String> selectedInterests = [];

  int minInterests = 1;
  late String articleID;
  late DocumentReference articleRef;
  late String imageURL;
  bool readToUpload = false;
  late String username;
  double uploadProgress = 0;
  File? pickedImage;

  final List<String> interests = [
    "GENERAL",
    "BUSINESS",
    "ENTERTAINMENT",
    //"environment",
    "FOOD",
    "HEALTH",
    "POLITICS",
    "SCIENCE",
    "SPORTS",
    "TECHNOLOGY",
    // "top",
    // "tourism",
    // "world",
  ];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        if (selectedInterests.length < 1) {
          selectedInterests.add(interest);
        } else {
          // Show a toast or display an error message indicating the limit has been reached
          print('Maximum selection limit reached');
        }
      }
    });
  }

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
                'Create a Post',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: RoundedButton(
                assetPath: "images/post.png",
                color: Colors.white,
                bgColor: Colors.transparent,
                onPressed: () {
                  final Reference storageReference = FirebaseStorage.instance
                      .ref()
                      .child('post_images')
                      .child('$articleID.jpg');
                  uploadPicture(storageReference, (double progress) {
                    // Handle progress updates here
                    print('Upload progress: $progress');
                    setState(() {
                      uploadProgress = progress;
                    });
                  }, (String imageUrl) {
                    print("Uploaded Image: ${imageUrl}");
                    imageURL = imageUrl;
                    readToUpload = true;
                  },9,19, (File? image) {
                    setState(() {
                      pickedImage = image;
                    });
                  });
                },
              ),
            ),
            if (uploadProgress > 0 && uploadProgress < 1.0)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: LinearProgressIndicator(
                  value: uploadProgress,
                ),
              ),
            if (pickedImage != null) Image.file(pickedImage!),
            Wrap(
              spacing: 14.0,
              runSpacing: 24.0,
              children: interests
                  .map(
                    (interest) => GestureDetector(
                      onTap: () => toggleInterest(interest.toLowerCase()),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color:
                            selectedInterests.contains(interest.toLowerCase())
                                ? Colors.blue //Color(COLOR_PRIMARY_VAL)
                                : Colors.grey.shade900,
                        child: Text(
                          "#$interest\t",
                          style: TextStyle(
                              color: selectedInterests
                                      .contains(interest.toLowerCase())
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade900,
        onPressed: () {
          // Handle the selected interests and navigate to the next page`
          if (selectedInterests.length >= minInterests) {
            if (readToUpload)
              uploadPost(context, selectedInterests);
            else
              AnimatedSnackBar.material(
                'Please Upload the image',
                type: AnimatedSnackBarType.info,
              ).show(context);
            print('Selected Interests: $selectedInterests');
          } else {
            print('Select at least $minInterests interests');
          }
        },
        label: Text(
          'DONE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        icon: Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getPrefs();
    articleRef = FirebaseFirestore.instance.collection("articles").doc();

    // Add a new document with an automatically generated push
    String pushId = articleRef.id;
    articleID = pushId;
    super.initState();
  }

  void uploadPost(BuildContext context, List<String> interestList) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isOnboarded', true);
    // await prefs.setStringList('interestList', interestList);

    Article article = Article(
        publishedAt: Timestamp.now(),
        articleId: articleID,
        category: interestList.elementAt(0),
        country: "in",
        title: "New Post",
        imageUrl: imageURL,
        summary: "This is a first user generated News Post",
        source: username,
        url: "https://www.google.com/");

    FirebaseDBOperations.updateArticle(articleID, article, () {
      Navigator.pop(context);
    });
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
