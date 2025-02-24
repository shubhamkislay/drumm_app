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
        width: 300,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: DrummTheme.drummPrimaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              child: Row(
                children: [
                  Image.asset(
                    "images/audio-waves.png",
                    color: DrummTheme.primaryTextColor(context),
                    height: 14,
                    width: 14,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Live',
                    style: TextStyle(
                        color:
                            Colors.white,
                        fontFamily: DRUMM_FONT_FAMILY,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: conversation.imageUrl ?? DEFAULT_APP_IMAGE_URL,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 12,
                ),
                Flexible(
                  child: AutoSizeText(
                    conversation.question ?? 'No Title',
                    softWrap: true,
                    minFontSize: 14,
                    maxFontSize: 24,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InstagramDateTimeWidget(
              fontColor: Colors.white.withAlpha(150),
                publishedAt: conversation.lastActive.toString()),
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
          channelName: conversation.conversationId ?? "",
          conversation: conversation,
        );
      },
      isScrollControlled: true, // optional for a full-screen bottom sheet
    );
  }
}
