import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/helper/firebase_db_operations.dart';
import 'live_drumms.dart';
import 'model/jam.dart';

class LiveIcon extends StatefulWidget {
  const LiveIcon({Key? key}) : super(key: key);

  @override
  State<LiveIcon> createState() => _LiveIconState();
}

class _LiveIconState extends State<LiveIcon> {
  bool liveDrummsExist = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.selection);
        setState(() {
          liveDrummsExist = false;
        });
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: COLOR_PRIMARY_DARK,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(0.0)),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0.0)),
                child: LiveDrumms(),
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(2.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: (liveDrummsExist)
                ? LinearGradient(colors: [
              Colors.grey.shade900,
              Colors.grey.shade900,
            ])
                : LinearGradient(colors: [
              COLOR_PRIMARY_DARK,
              COLOR_PRIMARY_DARK,
            ])),
        child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black,
          ),
          child: Image.asset(
            'images/drumm_logo.png',
            height: 22,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ), // data_saver_off_rounded Image.asset("images/hotspot.png",height: 24,fit: BoxFit.contain,color: Colors.white,))),
    );
  }

  @override
  void initState() {
    super.initState();
    checkLiveDrumms();
  }

  Future<void> checkLiveDrumms() async {
    List<Jam> fetchedDrumms = await FirebaseDBOperations.getDrummsFromBands();
    if (fetchedDrumms.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
      return;
    }
    List<Jam> broadcastJams = await FirebaseDBOperations.getBroadcastJams();
    if (broadcastJams.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
    }
    List<Jam> openDrumms = await FirebaseDBOperations.getOpenDrummsFromBands();
    if (openDrumms.length > 0) {
      setState(() {
        liveDrummsExist = true;
      });
    }
  }
}
