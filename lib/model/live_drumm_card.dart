import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/constants/Constants.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../jam_room_page.dart';
import '../theme/theme_constants.dart';
import 'article.dart';
import 'jam.dart';

class LiveDrummCard extends StatefulWidget {
  final Jam jam;
  JamCallback? jamCallback;
  bool? open;
  LiveDrummCard(
      this.jam, {
        Key? key,
        this.jamCallback,
        this.open
      })
      : super(key: key);

  @override
  State<LiveDrummCard> createState() => _HomeItemState();
}

class _HomeItemState extends State<LiveDrummCard> {
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900;
  double iconHeight = 64;
  double sizedBoxedHeight = 12;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: joinDrumm,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CURVE),
          topRight: Radius.circular(CURVE),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: COLOR_PRIMARY_DARK,
              borderRadius: BorderRadius.circular(CURVE),
              border: Border.all(color: Colors.grey.shade800, width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(CURVE),
                  topRight: Radius.circular(CURVE),
                ),
                child: CachedNetworkImage(
                  height: 125,
                  width: double.infinity,
                  imageUrl: widget.jam.imageUrl ?? "",
                  filterQuality: FilterQuality.low,
                  placeholder: (context, imageUrl) {
                    return SizedBox(
                      height: 125,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Image.asset("images/drumm_logo_main.png",height: 125,width: double.infinity,fit: BoxFit.cover,);
                  },
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AutoSizeText(
                    RemoveDuplicate.removeTitleSource(
                        widget.jam.title ?? ""),
                    textAlign: TextAlign.start,
                    maxLines: 4,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade700.withOpacity(0.75)
                ),
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
              ),
              SizedBox(height: 8,)
            ],
          ),
        ),
      ),
    );
  }

  void joinDrumm() {
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
  }

}
