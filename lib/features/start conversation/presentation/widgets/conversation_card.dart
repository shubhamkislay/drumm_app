import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationCard extends StatelessWidget {
  final ConversationEntity conversation;
  final DrummerEntity drummerEntity;

  const ConversationCard({Key? key, required this.conversation, required this.drummerEntity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        context.read<DrummAudioBloc>().add(
          StartOrSwitchChannelEvent(
            appId: DrummConstants.appId,
            token: DrummConstants.generateAgoraToken(drummerEntity.rid.toString(), conversation.conversationId??""),
            channelName: conversation.conversationId??"",
            uid: drummerEntity.rid??1234,
            isMuted: false,
          ),
        );
        _showCallBottomSheet(context);
      },
      child: Container(
        width: 200, // Adjust card width as needed.
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                conversation.title ?? 'Untitled',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                conversation.question ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCallBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DrummAudioBottomSheet(channelName:conversation.conversationId??"");
      },
      isScrollControlled: true, // optional for a full-screen bottom sheet
    );
  }
}