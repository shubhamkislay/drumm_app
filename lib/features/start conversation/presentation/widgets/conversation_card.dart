import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationCard extends StatelessWidget {
  final ConversationEntity conversation;
  final DrummerEntity drummerEntity;

  const ConversationCard(
      {Key? key, required this.conversation, required this.drummerEntity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DrummAudioBloc>().add(
              StartOrSwitchChannelEvent(
                conversation: conversation,
                appId: DrummConstants.appId,
                token: DrummConstants.generateAgoraToken(
                    drummerEntity.rid.toString(),
                    conversation.conversationId ?? ""),
                channelName: conversation.conversationId ?? "",
                uid: drummerEntity.rid ?? 1234,
                isMuted: false,
              ),
            );
        _showCallBottomSheet(context);
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: conversation.imageUrl ?? DEFAULT_APP_IMAGE_URL,
                height: double.maxFinite,
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: DrummTheme.primaryItemColor(context).withAlpha(220),//DrummTheme.drummPrimaryColor.withAlpha(200),//
                  borderRadius: BorderRadius.circular(20.0),
                )
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //InstagramDateTimeWidget(publishedAt: conversation.pinnedAt.toString()),
                      Flexible(
                        child: Text(
                          "Live",
                          softWrap: true,
                          style: TextStyle(color: DrummTheme.primaryTextColor(context), fontSize: 12),
                        ),
                      ),
                      Image.asset(
                        "images/audio-waves.png",
                        color: DrummTheme.primaryTextColor(context),
                        height: 14,
                        width: 14,
                      ),
                    ],
                  ),
                  Flexible(
                    child: AutoSizeText(
                      minFontSize: 16,
                      maxFontSize: 24,
                      conversation.question ?? 'No Title',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 24,
                          fontWeight: FontWeight.bold, color: DrummTheme.primaryTextColor(context)),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "${conversation.meta}",
                      maxLines: 1,
                      softWrap: true,
                      style: TextStyle(color: DrummTheme.primaryTextColor(context), fontSize: 12,fontFamily: DRUMM_FONT_FAMILY,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DrummAudioBottomSheet(
          drummerEntity: drummerEntity,
          channelName: conversation.conversationId ?? "",
          conversation: conversation,
        );
      },
      isScrollControlled: true, // optional for a full-screen bottom sheet
    );
  }
}
