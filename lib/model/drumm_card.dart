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
import '../custom/instagram_date_time_widget.dart';
import '../theme/theme_constants.dart';
import 'home_item.dart';

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
  double curve = CURVE;
  Drummer drummer = Drummer();
  Band band = Band();
  double bottomPadding = 80;

  @override
  Widget build(BuildContext context) {

    int boosts = 0;
    double curve = CURVE;
    double borderWidth = 3.5;
    double bottomPadding = 100;
    double horizontalPadding = 10;
    double maxTextSize = 20;
    double minTextSize = 14;

    DateTime currentTime = DateTime.now();
    DateTime recent = currentTime.subtract(Duration(hours: 3));
    Timestamp boostTime = Timestamp.now();
    Color fadeColor =
        COLOR_BACKGROUND; //COLOR_ARTICLE_BACKGROUND; //.withOpacity(0.8);


    Color colorBorder =
    (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0)
        ? COLOR_BOOST
        : Colors.grey.shade800
        .withOpacity(0.225); //COLOR_ARTICLE_BACKGROUND;//fadeColor;
    Color colorBorder2 =
    (boosts > 0 && boostTime.compareTo(Timestamp.fromDate(recent)) > 0)
        ? Colors.blueGrey
        : Colors.grey.shade800
        .withOpacity(0.225);

    return ClipRRect(
      borderRadius: BorderRadius.circular(curve),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        //width: widget.width ?? double.maxFinite,
        child: Stack(
          children: [
            Container(
              width:  double.maxFinite,
              height: 225,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(curve),
                  gradient: LinearGradient(colors: [
                    Colors.white12,
                    Colors.white12,
                    // Colors.blue.shade700,
                    // Colors.blue.shade400,
                  ])),
              padding: EdgeInsets.all(2.5),
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
                    child: Column(
                      children: [
                        Expanded(
                          //margin: EdgeInsets.only(bottom: bottomPadding),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
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
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          end: Alignment.bottomCenter,
                                          begin: Alignment.topCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.transparent,
                                            fadeColor,
                                          ])),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                            horizontalPadding - 2),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              curve - 4),
                                          color: Colors.white
                                              .withOpacity(0.1),
                                        ),
                                        child: AutoSizeText(
                                          "${band.name}",
                                          textAlign: TextAlign.left,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          maxLines: 1,
                                          minFontSize: 10,
                                          maxFontSize: 11,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily:
                                              APP_FONT_MEDIUM,
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding, vertical: 6),
                          //height: maxHeight,
                          child: AutoSizeText(
                            unescape.convert(
                                widget.jam.question ??
                                    widget.jam.title ??
                                    ""),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxFontSize: maxTextSize,
                            maxLines: 2,
                            minFontSize: minTextSize,
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: maxTextSize,
                                fontWeight: FontWeight.w200,
                                fontFamily: APP_FONT_BOLD,
                                color: Colors.white),
                          ),
                        ),
                       if(true) Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: horizontalPadding, bottom: 12),
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(12),
                                //color: Colors.grey.shade900.withOpacity(0.35),
                              ),
                              child: Text(
                                "${widget.jam.startedBy}  •  ",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: APP_FONT_MEDIUM,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  right: horizontalPadding, bottom: 12),
                              child: InstagramDateTimeWidget(
                                textSize: 10,
                                fontColor: Colors.white54,
                                publishedAt:
                                    widget.jam.lastActive.toString()??"",
                              ),
                            ),
                          ],
                        ),
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
