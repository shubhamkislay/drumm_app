import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/widgets/podcast_share_button.dart';
import 'package:flutter/material.dart';

class PodcastItemWidget extends StatelessWidget {

  final PodcastEntity podcast;
  const PodcastItemWidget({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          DrummTheme.drummPrimaryColor,
          Colors.blue
        ]),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            child: Row(
              children: [
                Image.asset("images/podcast.png",color: Colors.white.withAlpha(150),height: 18,width: 18,),
                SizedBox(width: 4,),
                Text("The Drumm Podcast",style: TextStyle(
                    color: Colors.white.withAlpha(150),//DrummTheme.primaryTextColor(context),
                    fontFamily: DRUMM_FONT_FAMILY,
                    fontWeight: FontWeight.bold,
                  fontSize: 12
                ),),
                Expanded(child: SizedBox()),
                PodcastShareButton(podcast: podcast, color: Colors.white,backgroundColor: Colors.white.withAlpha(20),),
              ],
            ),
          ),
          //SizedBox(height: 4,),
          Flexible(
            child: AutoSizeText(
              "${(podcast.podcastTitle.isNotEmpty)?podcast.podcastTitle:podcast.audioTitle}",
              textAlign: TextAlign.start,
              minFontSize: 16,
              maxFontSize: 28,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  color:Colors.white,//DrummTheme.primaryTextColor(context),
                  fontFamily: DRUMM_FONT_FAMILY,
                  fontWeight: FontWeight.bold,
                fontSize: 28
              ),
            ),
          ),
          //SizedBox(height: 4,),
          Text(
            "${CoreUtils.getWeekDay(podcast.updatedAt)} ${CoreUtils.getFormattedTime(podcast.updatedAt)}, ${CoreUtils.getFormattedDate(podcast.updatedAt)}",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12,
                color: Colors.white.withAlpha(150),//DrummTheme.primaryTextColor(context),
                fontFamily: DRUMM_FONT_FAMILY,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}
