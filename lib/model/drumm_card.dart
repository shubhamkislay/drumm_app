import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/band.dart';
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

import '../custom/helper/image_uploader.dart';
import '../theme/theme_constants.dart';

typedef void JamCallback(Jam jam);

class DrummCard extends StatefulWidget {
  final Jam jam;
  JamCallback? jamCallback;
  bool? open;
  double? width;

  DrummCard(this.jam, {Key? key, this.jamCallback, this.open, this.width})
      : super(key: key);

  @override
  State<DrummCard> createState() => _DrummCardState();
}

class _DrummCardState extends State<DrummCard> {
  double curve = 8;
  Drummer drummer = Drummer();
  Band band = Band();
  double bottomPadding = 80;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(curve),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        //width: widget.width ?? double.maxFinite,
        child: Stack(
          children: [
            Container(
              width: widget.width ?? double.maxFinite,
              height: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(curve),
                  gradient: LinearGradient(colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade400,
                  ])),
              padding: EdgeInsets.all(2),
              child: GestureDetector(
                onTap: () {
                  //Navigator.pop(context);
                  if (widget.jamCallback != null)
                    widget.jamCallback!(widget.jam);

                  //Navigator.pop(context);
                  joinDrumm();
                },
                child: Container(
                  //padding: EdgeInsets.all(0),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(curve),
                    color: Colors.black,//COLOR_ARTICLE_BACKGROUND,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(curve - 2),
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: bottomPadding),
                          child: CachedNetworkImage(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              placeholder: (context, url) => Container(
                                    color: Colors.grey.shade900,
                                  ),
                              errorWidget: (context, url, error) => Container(
                                    color: COLOR_PRIMARY_DARK,
                                  ),
                              imageUrl: widget.jam.imageUrl ?? "",
                              fit: BoxFit.cover),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            height: double.infinity,
                            margin:
                            EdgeInsets.only(bottom: bottomPadding),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    end: Alignment.bottomCenter,
                                    begin: Alignment.topCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      COLOR_ARTICLE_BACKGROUND,
                                    ])),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(4),
                            height: bottomPadding,
                            color: COLOR_ARTICLE_BACKGROUND,
                            //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: AutoSizeText(
                                      widget.jam.question ?? widget.jam.title ?? "",
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxFontSize: 15,
                                      maxLines: 3,
                                      minFontSize: 11,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 15,
                                          fontFamily: APP_FONT_MEDIUM,
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (band.url!=null)
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    width: 32,
                    height: 32,
                    imageUrl: modifyImageUrl(
                        band.url ?? "", "100x100"),
                    fit: BoxFit.cover,
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
    if(widget.jam.bandId!=null)
      getBandDetails();
  }

  void getBandDetails() async {
    FirebaseDBOperations.getBand(widget.jam.bandId??"").then((value) {
      setState(() {
        band = value;
      });
    });
  }

  void getDrummerDetails() async {
    FirebaseDBOperations.getDrummer(widget.jam.startedBy??"").then((value) {
      setState(() {
        drummer = value;
      });
    });
  }

  void joinDrumm() async {
    Jam rJam = await FirebaseDBOperations.getDrummsFromJamId(widget.jam);
    bool isBroadcast = rJam.broadcast ?? false;
    if (!FirebaseDBOperations.isTimestampWithin1Minute(
            rJam.lastActive ?? Timestamp.now()) &&
        !isBroadcast) {
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
              child: Container(
                height: 200,
                padding: EdgeInsets.all(36),
                color: Colors.grey.shade900,
                child: Center(
                  child: Text(
                    "This drumm has ended.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      );

      return;
    }

    bool isOpen = false;

    if (widget.open != null) isOpen = widget.open ?? false;
    FirebaseDBOperations.sendNotificationToTopic(
        widget.jam, false, widget.open ?? false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            child: JamRoomPage(
              jam: widget.jam,
              open: isOpen,
            ),
          ),
        );
      },
    );
  }
}
