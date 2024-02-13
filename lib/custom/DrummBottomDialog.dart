import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

import '../band_details_page.dart';
import '../model/article.dart';
import '../model/article_band.dart';
import '../model/band.dart';
import '../user_profile_page.dart';
import 'helper/firebase_db_operations.dart';
import 'helper/image_uploader.dart';

class DrummBottomDialog extends StatefulWidget {
  ArticleBand? articleBand;
  VoidCallback startDrumming;
  DrummBottomDialog({Key? key, required this.articleBand,required this.startDrumming}) : super(key: key);

  @override
  State<DrummBottomDialog> createState() => _DrummBottomDialogState();
}

class _DrummBottomDialogState extends State<DrummBottomDialog> {
  List<Container> memberCards = [];
  double drummerSize = 30;
  @override
  Widget build(BuildContext context) {
    BuildContext thisContext = context;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: COLOR_PRIMARY_DARK,
        //borderRadius: BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(12)),
      ),

      //height: 425,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.075),
                    borderRadius: BorderRadius.circular(24)
                  ),
                  padding:  const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BandDetailsPage(
                            band: widget.articleBand?.band,
                          ),
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    //margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.075), //.withOpacity(0.8),
                      //border: Border.all(color: Colors.grey.shade900.withOpacity(0.85),width: 2.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      widget.articleBand?.band?.name ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      width: 100,
                      height: 100,
                      imageUrl: widget.articleBand?.article?.imageUrl ??
                          "", //widget.article?.imageUrl ?? "",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorWidget: (context, url, error) {
                        return Container(color: COLOR_PRIMARY_DARK);
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),
                Container(
                  alignment: Alignment.center,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24),
                  child: AutoSizeText(
                    "\"${widget.articleBand?.article?.question??widget.articleBand?.article?.title}\"",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: APP_FONT_MEDIUM,
                        fontSize: 26,

                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: drummerSize,
                  width: double.infinity,
                  child: Center(
                    child: ListView(

                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: memberCards,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("A notification will be send to all the band members",style: TextStyle(color: Colors.white30,fontSize: 12),),
            ),
            SwipeButton.expand(
              thumbPadding: const EdgeInsets.all(4),
              height: 64,
              thumb: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'images/audio-waves.png',
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              borderRadius: BorderRadius.circular(22),
              child: const Text(
                "Swipe right to start drumming",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              activeThumbColor: Colors.blue.shade800,
              activeTrackColor: Colors.white.withOpacity(0.075),
              onSwipe: () {
                print("Drumming done...");
                Navigator.pop(thisContext);
                widget.startDrumming();

              },
            ),
          ],
        ),
      ),
    );
  }

  void getMembers() async {
    List<Drummer> drummers =
    await FirebaseDBOperations.getUsersByBand(widget.articleBand?.band ?? Band());

    setState(() {
      memberCards = drummers.map((e) {
        return Container(
          width: drummerSize,
          height: drummerSize,
          padding: const EdgeInsets.all(2),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      fromSearch: true,
                      drummer: e,
                    ),
                  ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                  width: drummerSize,
                  height: drummerSize,
                  imageUrl: modifyImageUrl(e.imageUrl ?? "","100x100"),
                  fit: BoxFit.cover),
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getMembers();
    super.initState();
  }
}
