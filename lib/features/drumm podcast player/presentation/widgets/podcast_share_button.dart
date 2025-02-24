import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/model/home_item.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:share_plus/share_plus.dart';

class PodcastShareButton extends StatelessWidget {
  PodcastEntity podcast;
  Color? color;
  Color? backgroundColor;
  PodcastShareButton({super.key, required this.podcast,this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return GestureDetector(
      onTap: (){
        analytics.logEvent(
          name: 'share_podcast',
          parameters: <String, Object>{
            'audio_url': podcast.audioUrl??"",
            'podcast_title': podcast.podcastTitle??"",
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        Vibrate.feedback(FeedbackType.selection);
        generateShareableLink();
      },
      child: Container(
        height: 32,
        width: 32,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor??DrummTheme.primaryDarkItemColor.withAlpha(150),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Image.asset('images/share-btn.png',
            color: color??DrummTheme.primaryTextColorDark,
            fit: BoxFit.contain),
      ),
    );
  }

  void generateShareableLink() async {
    try {
      final Map<String, String> metadataMap = podcast.toJson().map((key, value) {
        // Convert nulls to empty strings or handle them as needed.
        return MapEntry(key, value?.toString() ?? '');
      });

      String imageUrl = DEFAULT_APP_IMAGE_URL;
      BranchContentMetaData metadata = BranchContentMetaData();
      BranchLinkProperties lp = BranchLinkProperties();
      late BranchUniversalObject buo;
      metadata = BranchContentMetaData()
        ..addCustomMetadata('podcast', metadataMap);

      buo = BranchUniversalObject(
          canonicalIdentifier: 'flutter/branch',
          title: "Check out the latest podcast on Drumm!",
          imageUrl: imageUrl,
          contentDescription: unescape.convert(podcast.podcastTitle ?? ""),
          contentMetadata: metadata,
          publiclyIndex: true,
          locallyIndex: true,
          expirationDateInMilliSec: DateTime
              .now()
              .add(const Duration(days: 365))
              .millisecondsSinceEpoch);

      lp = BranchLinkProperties(
          channel: 'facebook',
          feature: 'sharing',
          stage: 'new share',
          campaign: 'campaign',
          tags: ['one', 'two', 'three'])
        ..addControlParam('\$uri_redirect_mode', '1')..addControlParam(
            '\$ios_nativelink', true)..addControlParam(
            '\$match_duration', 7200)..addControlParam(
            '\$always_deeplink', true)..addControlParam(
            '\$android_redirect_timeout', 750)..addControlParam(
            'referring_user_id', 'user_id');

      BranchResponse response =
      await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

      if (response.success) {
        if (kDebugMode) {
          print('GeneratedLink : ${response.result}');
        }
        String articleLink =
            "${(podcast.podcastTitle != null)
            ? "${unescape.convert(podcast.podcastTitle ?? "")}"
            : unescape.convert(podcast.audioTitle ??
            "")}\n\nTap to listen to the podcast on Drumm.\n${response.result}";
        Share.share(articleLink);
      } else {
        if (kDebugMode) {
          print('Error : ${response.errorCode} - ${response.errorMessage}');
        }
      }
    }catch(e){
      if (kDebugMode) {
        print("unable to generate link: $e");
      }
    }
  }
}
