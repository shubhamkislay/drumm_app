import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/DrummBottomQuestion.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../question_jam_room.dart';
import '../theme/theme_constants.dart';

typedef void DeleteCallback(Question? question);
class QuestionCard extends StatefulWidget {


  Question? question;
  double? cardWidth;
  double? cardHeight;
  bool? deleteItem;
  DeleteCallback? deleteCallback;


  QuestionCard(
      {
        Key? key,
        this.question,
        this.cardWidth,
        this.cardHeight,
        this.deleteItem,
        this.deleteCallback,
      }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  double curve = 12;
  Drummer drummer = Drummer();
  @override
  Widget build(BuildContext context) {
    double cardHeight = widget.cardHeight??500;
    double cardWidth = widget.cardHeight??325;





    return GestureDetector(
      onTap: (){
        drumJoinDialog();
      },
      child: Container(
        width: cardWidth,
        //height: cardHeight,
        decoration: BoxDecoration(
          color:COLOR_ARTICLE_BACKGROUND,//Colors.grey.shade900,
            borderRadius: BorderRadius.circular(curve),
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
        child: GestureDetector(
          onTap: () {
            drumJoinDialog();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(drummer.imageUrl!=null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(imageUrl: drummer.imageUrl??"",width: 54,height: 54,)),
                  SizedBox(width: 8,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 0,height: 12,),
                            Flexible(child: Text(drummer.username??"",style: const TextStyle(overflow: TextOverflow.ellipsis,fontSize: 15,fontWeight: FontWeight.w600,fontFamily: APP_FONT_MEDIUM,),)),
                            const Text(" • "),
                            Flexible(child: InstagramDateTimeWidget(publishedAt: widget.question?.createdTime.toString()??Timestamp.now().toString())),
                            //Text(widget.question?.hook??"",textAlign: TextAlign.end,style: TextStyle(fontSize: 12,color: Colors.white38),)
                          ],
                        ),
                        Text("${drummer?.jobTitle??""}",textAlign: TextAlign.center,style: const TextStyle(color: Colors.white70,fontSize: 12),),
                        Text("${drummer?.occupation??""}",maxLines:1,textAlign: TextAlign.left,style: const TextStyle(color: Colors.white30,fontSize: 12,),overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: AutoSizeText("${widget.question?.query}".trim(),
                  maxLines: 3,
                  minFontSize: 12,
                  maxFontSize: 16,
                  //softWrap: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: APP_FONT_LIGHT,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async{
    Drummer fetchDrummer = await FirebaseDBOperations.getDrummer(widget.question?.uid??"");


    setState(() {
      drummer = fetchDrummer;
    });
  }

  void drumJoinDialog() {
    Vibrate.feedback(FeedbackType.selection);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DrummBottomQuestionDialog(
          question: widget.question,
          deleteItem: widget.deleteItem??
              (FirebaseAuth.instance.currentUser?.uid == widget.question?.uid),
          startDrumming: () {
            if(widget.deleteItem??(FirebaseAuth.instance.currentUser?.uid == widget.question?.uid)) {
              Vibrate.feedback(FeedbackType.impact);
              deleteQuestion();
              try {
                widget.deleteCallback!(widget.question);
              }catch(e){}
            }else{
              Vibrate.feedback(FeedbackType.success);
              joinOpenDrumm(widget.question ?? Question(), drummer);
            }
          },
          drummer: drummer,
        );
      },
    );
  }

  void deleteQuestion() async{
    FirebaseDBOperations.deletedQuestionsAskedByQuestionId(FirebaseAuth.instance.currentUser?.uid??"", widget.question?.qid??"");
  }

  void joinOpenDrumm(Question question, Drummer drummer) {
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = question.query;
    jam.bandId = question.uid;
    jam.jamId = question.qid;
    jam.articleId = "";
    jam.startedBy = FirebaseAuth.instance.currentUser?.uid??"";
    jam.imageUrl = drummer.imageUrl;
    jam.question =  question.query;
    jam.lastActive = Timestamp.now();
    jam.count = 0;
    jam.membersID = [];


    FirebaseDBOperations.addMemberToJam(question.qid ?? "",
        FirebaseAuth.instance.currentUser?.uid ?? "", true)
        .then((value) {
      print("Added the member ${value}");
      if (!value) {
        print("Creating drumm///////////////////////////////////////");
        FirebaseDBOperations.createOpenDrumm(jam);
      }

      //FirebaseDBOperations.sendNotificationToTopic(jam, false, true);

      //FirebaseDBOperations.sendRingingNotification(drummer.token??"", jam);

      FirebaseDBOperations.sendNotificationToDrummer(drummer.token??"",jam, true, true);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: COLOR_PRIMARY_DARK,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(0.0)),
            child: QuestionJamRoomPage(
              question: widget.question,
              jam: jam,
              open: true,
            ),
          ),
        );
      },
    );
  }
}
