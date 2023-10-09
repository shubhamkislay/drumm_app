import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'custom/helper/connect_channel.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'jam_room_page.dart';
import 'model/jam.dart';

class NotificationItem extends StatefulWidget {
  String message;
  NotificationItem({Key? key,required this.message}) : super(key: key);

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  String drummerImage="";
  String drummerUsername ="";
  Drummer? drummer;
  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> jsonMessage = jsonDecode(widget.message);
    final Map<String, dynamic> dataJson = jsonMessage['data'] ?? {};
    String drummerID = dataJson["drummerID"].toString();
    bool open = jsonDecode(dataJson["open"]);
    Map<String, dynamic> json = jsonDecode(dataJson["jam"]);
    Jam jam = Jam.fromJson(json);
    getDrummer(drummerID);
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade900,width: 1)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: COLOR_PRIMARY_DARK,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(drummerImage.length>1)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: drummerImage,
                          fit: BoxFit.cover,
                          width: 20,
                          height: 20,
                        )),
                    SizedBox(
                      width: 4,
                    ),
                    if(drummerUsername.length>1)
                    GestureDetector(
                      onTap: () {
                        if (jam.jamId != ConnectToChannel.channelID) {
                          joinRoom(jam, open, false);
                          FirebaseDBOperations.sendNotificationToTopic(jam,false,open);
                        }
                      },
                      child: Text(
                        "${drummerUsername} joined the drumm",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: jam.imageUrl??"",
                                  fit: BoxFit.cover,
                                  width: 72,
                                  height: 72,
                                  errorWidget: (context,url,error) => Container(width: 72,
                                    height: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: COLOR_PRIMARY_DARK,
                                  ),),
                                ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (jam.jamId != ConnectToChannel.channelID) {
                                      joinRoom(jam, open, false);
                                      FirebaseDBOperations.sendNotificationToTopic(jam,false,open);
                                    }
                                  },
                                  child: Text(
                                    "${jam.title}",
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                            SizedBox(
                              width: 4,
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (jam.jamId != ConnectToChannel.channelID) {
                        joinRoom(jam, open, false);
                        FirebaseDBOperations.sendNotificationToTopic(jam,false,open);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Drop in",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  void joinRoom(Jam jam, bool open,bool ring) {
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
              jam: jam,
              open: open,
              ring:ring,
            ),
          ),
        );
      },
    );
  }

  void getDrummer(String drummerID) async{
    drummer = await FirebaseDBOperations.getDrummer(drummerID);
    setState(() {
      drummerImage = modifyImageUrl(drummer?.imageUrl ?? "", "100x100");
      drummerUsername = drummer?.username ?? "";
    });

  }
}
