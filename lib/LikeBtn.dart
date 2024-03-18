import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/constants/Constants.dart';
import 'custom/helper/connect_channel.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/article.dart';

typedef void BoostedCallback(bool boosted);
class LikeBtn extends StatefulWidget {
  Article article;
  String? queryID;
  bool userBoosted;
  BoostedCallback? boostedCallback;
  LikeBtn({super.key, required this.article, this.queryID, this.boostedCallback, required this.userBoosted});

  @override
  State<LikeBtn> createState() => _LikeBtnState();
}

class _LikeBtnState extends State<LikeBtn> {
  @override
  Widget build(BuildContext context) {

    int boosts = 0;
    //checkIfUserLiked();

    DateTime currentTime = DateTime.now();
    DateTime recent = currentTime.subtract(Duration(hours: 3));
    Timestamp boostTime = Timestamp.now();
    try {
      boostTime = widget.article!.boostamp ?? Timestamp.now();
      boosts = widget.article?.boosts ?? 0;
    }catch(e){

    }

    return GestureDetector(
      onTap: () {
        if(!widget.userBoosted){
          final player = AudioPlayer();
          //player.play(AssetSource("air.wav"));
        }
        likeArticle(widget.userBoosted??false);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: widget.userBoosted??false
                ? COLOR_BOOST
                : Colors.grey.shade900,width: 2.25)),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            color: widget.userBoosted??false
                ? COLOR_BOOST.withOpacity(0.5)
                : COLOR_BACKGROUND,//Colors.black.withOpacity(0.5),

          ),
          child: Image.asset(
            widget.userBoosted??false
                ? 'images/boost_enabled.png'//'images/heart_like.png'
                : 'images/boost_disabled.png',//'images/like_btn.png',
            height: widget.userBoosted??false
                ? 24
                : 18,
            color: widget.userBoosted??false
                ? Colors.white
                : Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void likeArticle(bool liked) {
    setState(() {
      if (liked) {
        FirebaseDBOperations.removeBoost(
            widget.article.articleId);
      } else {
        FirebaseDBOperations.updateBoosts(
            widget.article.articleId);
      }
      setState(() {
        if (widget.userBoosted??false) {
          widget.userBoosted = false;
        } else {
          widget.userBoosted= true;
          Vibrate.feedback(FeedbackType.success);
        }
      });
    });

    widget.boostedCallback!(widget.userBoosted??false);
  }

  void checkIfUserLiked() async {
    print("Checking if user boosted");
    FirebaseDBOperations.hasBoosted(
        widget.article?.articleId)
        .then((value) {
      setState(() {
        widget.userBoosted = value;

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    //checkIfUserLiked();
  }
}
