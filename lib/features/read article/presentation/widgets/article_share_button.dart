import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/model/home_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:share_plus/share_plus.dart';

class ArticleShareButton extends StatelessWidget {
  ArticleEntity article;
  ArticleShareButton({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Vibrate.feedback(FeedbackType.selection);
        context
            .read<UserActivityBloc>()
            .add(RecordUserActivity(UserActivityEntity(
          type: INTERACTION_SHARED,
          weight: WEIGHT_SHARED,
          articleId: article.articleId!,
          embedding: article.embedding!,
        )));
        generateShareableLink();
      },
      child: Container(
        height: 36,
        width: 36,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DrummTheme.primaryDarkItemColor.withAlpha(150),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Image.asset('images/share-btn.png',
            color: DrummTheme.primaryTextColorDark,
            fit: BoxFit.contain),
      ),
    );
  }

  void generateShareableLink() async {
    try {
      final Map<String, String> metadataMap = article.toJson().map((key, value) {
        // Convert nulls to empty strings or handle them as needed.
        return MapEntry(key, value?.toString() ?? '');
      });

      String imageUrl = article.imageUrl ??"https://cdn.prod.website-files.com/62d84e447b4f9e7263d31e94/6399a4d27711a5ad2c9bf5cd_ben-sweet-2LowviVHZ-E-unsplash-1.jpeg";//?? DEFAULT_APP_IMAGE_URL;
      BranchContentMetaData metadata = BranchContentMetaData();
      BranchLinkProperties lp = BranchLinkProperties();
      late BranchUniversalObject buo;
      metadata = BranchContentMetaData()
        ..addCustomMetadata('article', metadataMap);

      buo = BranchUniversalObject(
          canonicalIdentifier: 'flutter/branch',
          title: "${article.meta}",
          imageUrl: imageUrl,
          contentDescription: unescape.convert(article.title ?? ""),
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
            "${(article.title != null)
            ? "${unescape.convert(article.title ?? "")}"
            : unescape.convert(article.meta ??
            "")}\n\nTap to read the article on Drumm.\n${response.result}";
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
