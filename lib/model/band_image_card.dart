import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/view_band.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../custom/constants/Constants.dart';
import '../custom/helper/BottomUpPageRoute.dart';
import '../custom/helper/image_uploader.dart';

typedef void BandCallback(Band band);

class BandImageCard extends StatefulWidget {
  final Band band;
  bool? onlySelectable = true;
  BandCallback? bandCallback;
  bool? selected = false;

  BandImageCard(this.band, {Key? key, this.onlySelectable, this.bandCallback})
      : super(key: key);

  @override
  State<BandImageCard> createState() => BandImageCardState();


}

class BandImageCardState extends State<BandImageCard> {

  List<Container> memberCards = [];

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        onSelected();
      },
      child:  ClipRRect(
              borderRadius: BorderRadius.circular(CURVE),
              child: Container(
                decoration: BoxDecoration(
                  color: COLOR_PRIMARY_DARK,
                    borderRadius: BorderRadius.circular(CURVE),
                  border: Border.all(color: Colors.grey.shade900, width: 1)
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(CURVE-4),
                          child: Hero(
                            tag: widget.band.url??"",
                            child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                imageUrl:modifyImageUrl(widget.band.url ?? "","300x300"),
                                errorWidget:(context,url,error){
                                  return Container(color:COLOR_PRIMARY_DARK);
                                },
                                placeholder: (context, imageUrl) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.transparent,
                                  );
                                },
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       if(false) Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                "${widget.band.count} Members",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                minFontSize: 8,
                                style: const TextStyle(
                                    fontSize: 8,
                                    //fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ).frosted(
                                blur: 3, frostColor: Colors.grey.shade900),
                          ],
                        ),
                       if(!widget.onlySelectable!) Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: memberCards,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 12,top: 8),
                          child: AutoSizeText(
                            RemoveDuplicate.removeTitleSource(widget.band.name ?? ""),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxFontSize: 12,
                            maxLines: 3,
                            minFontSize: 8,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: APP_FONT_MEDIUM,
                                //fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
  void onSelected(){
    if (!widget.onlySelectable!) {
      Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) =>
                BandDetailsPage(
                  band: widget.band,
                ),
          ));

    } else {
      if(!(widget.selected??false)) {
        print("Selected");
        widget.bandCallback!(widget.band);
        setState(() {
          widget.selected = true;
        });
      }else{
        print("Deselected");
        setState(() {
          widget.selected = false;
        });
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembers();
  }

  void getMembers() async{

    List<Drummer> drummers = await FirebaseDBOperations.getUsersByBand(widget.band);

    setState(() {
      memberCards = drummers.map((e) {
        return Container(
          padding: EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
                width: 20,
                height: 20,
                imageUrl: modifyImageUrl(e.imageUrl ?? "","100x100"),
                fit: BoxFit.cover),
          ),
        );
      }).toList();
    });


  }

}
