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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //InstagramDateTimeWidget(publishedAt: conversation.pinnedAt.toString()),
                Text("Live", style: TextStyle(color: Colors.white,fontSize: 12),),
                  Image.asset("images/audio-waves.png",color: Colors.white,height: 14,width: 14,),
              ],
            ),
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: conversation.imageUrl??DEFAULT_APP_IMAGE_URL,width: 36,height: 36,fit: BoxFit.cover,)),
                SizedBox(width: 12,),
                Flexible(
                  child: AutoSizeText(
                    minFontSize: 12,
                    maxFontSize: 24,
                    conversation.question ?? 'No Title',
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
