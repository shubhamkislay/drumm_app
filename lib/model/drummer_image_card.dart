import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/user_profile_page.dart';

class DrummerImageCard extends StatelessWidget {
   Drummer drummer;

  DrummerImageCard(
      this.drummer, {
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
               fromSearch: true,
                drummer: drummer,
              ),
            ));
      },
      child: (drummer.imageUrl != null)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(color: Colors.grey.shade900,),
                imageUrl: modifyImageUrl(drummer?.imageUrl ??"","300x300"), fit: BoxFit.cover),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      begin: Alignment.topCenter,
                      colors: [
                        // Colors.grey.shade900.withOpacity(0.75),
                        Colors.transparent,
                        //Colors.black87,
                        Colors.grey.shade900
                        //RandomColorBackground.generateRandomVibrantColor()
                            .withOpacity(0.85)
                      ]
                  )
              ),
              //RandomColorBackground.generateRandomVibrantColor().withOpacity(0.55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          "${drummer.username}",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          minFontSize: 8,
                          style: TextStyle(
                              fontSize: 8,
                              //fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ).frosted(blur: 3,frostColor: Colors.grey.shade900),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: AutoSizeText(
                      RemoveDuplicate.removeTitleSource(drummer.name??""),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 14,
                      maxLines: 3,
                      minFontSize: 8,

                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,

                          //fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
          : Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: RandomColorBackground.generateRandomVibrantColor(),
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [Colors.black, Colors.grey.shade900],
          // ),
        ),
        child: AutoSizeText(
          drummer.name??"",
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 6,
          style: TextStyle(
            //fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
