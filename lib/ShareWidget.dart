
import 'dart:async';

import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'model/article.dart';
import 'model/home_item.dart';
import 'model/jam.dart';

class ShareWidget extends StatelessWidget {
  double? iconHeight;
  Article? article;
  Color? backgroundColor;
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();



  ShareWidget(
      {Key? key,
        this.backgroundColor,
        this.iconHeight,this.article})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconH = iconHeight??24;
    Widget widgetParent = ShareWidgetDesign(iconHeight: iconH,);
    if(article!=null) {
      widgetParent = GestureDetector(
        onTap: (){
          Vibrate.feedback(FeedbackType.selection);
          generateLink();
        },
        child: ShareWidgetDesign(iconHeight: iconH,backgroundColor: backgroundColor),
      );
    }

    return widgetParent;
  }

  void generateLink() async {
    String imageUrl = article?.imageUrl ?? DEFAULT_APP_IMAGE_URL;
    String source = article?.source ?? "";
    if (source.toLowerCase() == "youtube") {
      imageUrl = YoutubePlayer.getThumbnail(
          videoId:
          YoutubePlayer.convertUrlToId(article?.url ?? "") ?? "");
    }
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = unescape.convert(article?.title ?? "");
    jam.bandId = article?.category;
    jam.jamId = article?.jamId;
    jam.articleId = article?.articleId;
    jam.startedBy = article?.source;
    jam.imageUrl = imageUrl;
    if (article?.question != null) {
      jam.question = unescape.convert(article?.question ?? "");
    } else {
      jam.question = unescape.convert(article?.title ?? "");
    }
    jam.count = 1;
    jam.membersID = [];
    //jam.lastActive = Timestamp.now();

    metadata = BranchContentMetaData()..addCustomMetadata('jam', jam.toJson());

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: "Drop-in Audio discussion on Drumm",
        imageUrl: imageUrl,
        contentDescription: '${unescape.convert(article?.title ?? "")}',
        contentMetadata: metadata,
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');

    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

    if (response.success) {
      //if (context.mounted) {
      print('GeneratedLink : ${response.result}');

      String articleLink =
          "${(article?.question != null) ? "Drumm: ${unescape.convert(article?.question ?? "")}" : unescape.convert(article?.title ?? "")}\n\nTap to join the discussion on Drumm.\n${response.result}";

      Share.share(articleLink);

      // await Clipboard.setData(ClipboardData(text: response.result)).then((value) {
      // });

      // }
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }
}


class ShareWidgetDesign extends StatelessWidget {
  double? iconHeight;
  Color? backgroundColor;
  ShareWidgetDesign({Key? key,this.iconHeight,this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconH = iconHeight??24;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding:  EdgeInsets.all(iconHeight!/24 +12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: backgroundColor??Colors.grey.shade900.withOpacity(0.35),
          ),
          child: Image.asset(
            'images/share-btn.png',
            height: iconH,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
