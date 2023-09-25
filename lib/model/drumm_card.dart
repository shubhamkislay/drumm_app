import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

typedef void JamCallback(Jam jam);
class DrummCard extends StatefulWidget {
  final Jam jam;
  JamCallback? jamCallback;
  bool? open;

  DrummCard(
      this.jam, {
        Key? key,
        this.jamCallback,
        this.open
      }) : super(key: key);

  @override
  State<DrummCard> createState() => _DrummCardState();
}

class _DrummCardState extends State<DrummCard> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade900
            ]
          )
        ),
        padding: EdgeInsets.all(2),
        child: GestureDetector(
          onTap: () {
            //Navigator.pop(context);
            if(widget.jamCallback!=null)
              widget.jamCallback!(widget.jam);

            bool isOpen = false;

            if(widget.open!=null)
              isOpen = widget.open??false;

            FirebaseDBOperations.sendNotificationToTopic(widget.jam,false,widget.open??false);

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
                    child: JamRoomPage(jam: widget.jam, open: isOpen,),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    height: double.maxFinite,
                      width: double.maxFinite,
                      placeholder: (context, url) => Container(color: Colors.grey.shade900,),
                      errorWidget: (context,url,error) => Container(color: COLOR_PRIMARY_DARK,),
                      imageUrl: widget.jam.imageUrl ?? "", fit: BoxFit.cover),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                            colors: [
                              // Colors.grey.shade900.withOpacity(0.75),
                              Colors.transparent,
                              //Colors.black87,
                              Colors.grey.shade900
                              //RandomColorBackground.generateRandomVibrantColor()
                                  .withOpacity(0.85),
                            ]
                        )
                    ),
                    //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade700.withOpacity(0.75)
                              ),
                              child: AutoSizeText(
                                "${widget.jam.count} joined",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                minFontSize: 8,
                                style: TextStyle(
                                    fontSize: 8,
                                    //fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: AutoSizeText(
                            RemoveDuplicate.removeTitleSource(widget.jam.title??""),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxFontSize: 14,
                            maxLines: 3,
                            minFontSize: 8,

                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,

                                //fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
