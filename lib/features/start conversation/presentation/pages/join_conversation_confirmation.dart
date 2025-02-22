import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinConversationConfirmation extends StatelessWidget {
  final DrummerEntity drummerEntity;
  final ConversationEntity conversation;

  const JoinConversationConfirmation({
    Key? key, required this.drummerEntity, required this.conversation
  }) ;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5, // 50% of the screen height
      child: Container(
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Optional drag handle indicator
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.0),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: DrummTheme.primaryTextColor(context),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${conversation.meta}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed:
                          () {
                        Navigator.of(context).pop(false);
                      },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                          () {
                        Navigator.of(context).pop(true);
                        try {
                          context.read<DrummAudioBloc>().add(
                            StartOrSwitchChannelEvent(
                              appId: DrummConstants.appId,
                              token: DrummConstants.generateAgoraToken(
                                  drummerEntity.rid.toString(),
                                  conversation.conversationId ?? ""),
                              channelName: conversation.conversationId ?? "",
                              uid: drummerEntity.rid!,
                              isMuted: false,
                            ),
                          );
                        }catch(e){
                          return;
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return DrummAudioBottomSheet(channelName: conversation.conversationId ?? "");
                          },
                          isScrollControlled: true, // optional for a full-screen bottom sheet
                        );
                      },
                  child: Text('Join'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
