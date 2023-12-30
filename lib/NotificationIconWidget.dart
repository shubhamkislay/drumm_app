import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_widget.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  bool showNotification = false;
  @override
  Widget build(BuildContext context) {
    double iconSize = 30;

    return SizedBox(
      height: iconSize,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Vibrate.feedback(FeedbackType.selection);
              setState(() {
                showNotification = false;
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
                      child: NotificationWidget(),
                    ),
                  );
                },
              );
            },
            child: Container(
                padding: EdgeInsets.all(2),
                child: Image.asset(
                  showNotification
                      ? "images/notification_active.png"
                      : "images/notification_inactive.png",
                  height: iconSize - 4,
                  fit: BoxFit.contain,
                  color: Colors.white,
                )), //Icon(Icons.notifications_on_rounded,size: 32))),
          ),
        ],
      ),
    );
  }

  void getNotifications() async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");

    int notifLen = notifications?.length ?? 0;

    if (notifLen > 0) {
      setState(() {
        showNotification = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();
  }
}
