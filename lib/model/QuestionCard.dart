import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';

import '../theme/theme_constants.dart';

class QuestionCard extends StatefulWidget {

  Question? question;

  QuestionCard(
      {
        Key? key,
        this.question
      }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  double curve = 12;
  @override
  Widget build(BuildContext context) {
    return Container(

      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(curve),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            SingleChildScrollView(child: Text("${widget.question?.query}")),
            SizedBox(),
          ],
        ),
      ),
    );
  }

}
