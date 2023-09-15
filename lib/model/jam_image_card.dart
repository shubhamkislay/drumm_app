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

typedef void JamCallback(Jam jam);
class JamImageCard extends StatefulWidget {
  final Jam jam;
  JamCallback? jamCallback;

  JamImageCard(
      this.jam, {
        Key? key,
        this.jamCallback
      }) : super(key: key);

  @override
  State<JamImageCard> createState() => _JamImageCardState();
}

class _JamImageCardState extends State<JamImageCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Navigator.pop(context);
        if(widget.jamCallback!=null)
          widget.jamCallback!(widget.jam);

        FirebaseDBOperations.sendNotificationToTopic(widget.jam,false,false);
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
                child: JamRoomPage(jam: widget.jam,open: false,),
              ),
            );
          },
        );
      },
      child: (widget.jam.imageUrl != null)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(color: Colors.grey.shade900,),
                imageUrl: widget.jam.imageUrl ?? "", fit: BoxFit.cover),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(3),
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
                            .withOpacity(0.85)
                      ]
                  )
              ),
              //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            "${widget.jam.membersID?.length} joined",
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            minFontSize: 8,
                            style: TextStyle(
                                fontSize: 8,
                                //fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ).frosted(blur: 3,frostColor: Colors.grey.shade900),
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
              ),
            )
          ],
        ),
      )
          : Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: RandomColorBackground.generateRandomVibrantColor(),
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [Colors.black, Colors.grey.shade900],
          // ),
        ),
        child: AutoSizeText(
          widget.jam.title??"",
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 6,
          style: TextStyle(
            //fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
