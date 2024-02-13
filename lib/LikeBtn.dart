import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/helper/connect_channel.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/article.dart';

class LikeBtn extends StatefulWidget {
  Article article;
  String? queryID;
  LikeBtn({super.key, required this.article, this.queryID});

  @override
  State<LikeBtn> createState() => _LikeBtnState();
}

class _LikeBtnState extends State<LikeBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        likeArticle(widget.article.liked??false);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: Colors.grey.shade900,width: 2.25)),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            color: Colors.black.withOpacity(0.5),

          ),
          child: Image.asset(
            widget.article.liked??false
                ? 'images/heart_like.png'
                : 'images/like_btn.png',
            height: 18,
            color: widget.article.liked??false
                ? Colors.red
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
        FirebaseDBOperations.removeLike(
            widget.article.articleId);
      } else {
        FirebaseDBOperations.updateLike(
            widget.article.articleId);
      }
      setState(() {
        if (widget.article.liked??false) {
          widget.article.liked = false;
        } else {
          widget.article.liked = true;
          Vibrate.feedback(FeedbackType.success);
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
