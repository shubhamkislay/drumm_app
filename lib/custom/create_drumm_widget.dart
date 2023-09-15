import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class CreateDrummWidget extends StatefulWidget {
  Drummer? drummer;
  final VoidCallback onPressed;
  CreateDrummWidget({Key? key, required this.drummer,required this.onPressed}) : super(key: key);

  @override
  State<CreateDrummWidget> createState() => _CreateDrummWidgetState();
}

class _CreateDrummWidgetState extends State<CreateDrummWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 100,
        height: 200,
        color:  Colors.grey.shade900,
        padding: EdgeInsets.all(1),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    placeholder: (context, url) => Container(color: Colors.grey.shade900,),
                    errorWidget: (context,url,error) => Container(color: COLOR_PRIMARY_DARK,),
                    imageUrl: widget.drummer?.imageUrl ?? "", fit: BoxFit.cover),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
                          colors: [
                            // Colors.grey.shade900.withOpacity(0.75),
                            Colors.black
                                .withOpacity(0.7),
                            //Colors.black87,
                            Colors.black
                                .withOpacity(0.7),
                          ]
                      )
                  ),
                  //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue
                            ),
                            child: AutoSizeText(
                              "Create",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              minFontSize: 8,
                              style: TextStyle(
                                  fontSize: 8,
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: AutoSizeText(
                          "New",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: 14,
                          maxLines: 3,
                          minFontSize: 8,

                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
