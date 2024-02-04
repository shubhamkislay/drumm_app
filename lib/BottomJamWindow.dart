import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/connect_channel.dart';
import 'custom/listener/connection_listener.dart';
import 'jam_room_page.dart';
import 'model/jam.dart';

class BottomJamWindow extends StatefulWidget {
  const BottomJamWindow({Key? key}) : super(key: key);

  @override
  State<BottomJamWindow> createState() => _BottomJamWindowState();
}

class _BottomJamWindowState extends State<BottomJamWindow> {
  bool userConnected = false;
  late Jam currentJam = Jam();
  bool openDrumm = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (userConnected) ?
    GestureDetector(
      onTap: () {
        try{
          Navigator.pop(ConnectToChannel.jamRoomContext);
        }catch(e){
        }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(0.0)),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom:
                  MediaQuery.of(context).viewInsets.bottom),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0.0)),
                child: JamRoomPage(
                  jam: currentJam,
                  open: openDrumm,
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(
          horizontal: 0,
        ),
        margin:
        EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
            color: COLOR_PRIMARY_DARK,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.grey.shade900, width: 1)),
        child: Row(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: currentJam.imageUrl ?? "",
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                  errorWidget: (context, url, error) =>
                      Container(color: COLOR_PRIMARY_DARK),
                ),
              ),
            ),
            Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(
                      vertical: 4, horizontal: 4),
                  child: Text(
                    "${currentJam.title}",
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                        fontFamily: APP_FONT_MEDIUM,
                        fontSize: 14),
                  ),
                )),
            GestureDetector(
              onTap: () {

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TutorialBox(
                      boxType: BOX_TYPE_CONFIRM,
                      sharedPreferenceKey: CONFIRM_JOIN_SHARED_PREF,
                      tutorialImageAsset: "images/audio-waves.png",
                      tutorialMessage: LEAVE_DRUMM_CONFIRMATION,
                      tutorialMessageTitle: LEAVE_DRUMM_TITLE,
                      confirmColor: Colors.redAccent,
                      confirmMessage: "Confirm",
                      onConfirm: (){
                        Vibrate.feedback(FeedbackType.selection);
                        ConnectToChannel.leaveChannel();
                        FlutterCallkitIncoming.endAllCalls();

                      },
                    );
                  },
                );


              },
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(18),
                ),
                //  child: Transform.rotate(angle: 180 * 3.1415927 / 180,
                child: Image.asset(
                  "images/leave.png",
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
                //  ),
              ),
            )
          ],
        ),
      ),
    ):Container(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenToJamState();
  }

  void listenToJamState() {
    ConnectionListener.onConnectionChanged = (connected, jam, open) {
      // Handle the channelID change here
      // print("onConnectionChanged called in Launcher");
      setState(() {
        // Update the UI with the new channelID
        openDrumm = open;
        currentJam = jam;
        userConnected = connected;
      });
    };
  }
}
