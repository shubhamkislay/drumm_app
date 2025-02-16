import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PinnedConversationsWidget extends StatelessWidget {
  const PinnedConversationsWidget({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dispatch the event to load pinned conversations when the widget is built.
    context.read<PinnedConversationsBloc>().add(LoadPinnedConversationsEvent());

    return BlocBuilder<RemoteDrummerBloc, RemoteDrummerState>(
      builder: (context,drummerState) {
        if(drummerState is RemoteDrummerDone) {
          return BlocBuilder<PinnedConversationsBloc, PinnedConversationsState>(
          builder: (context, state) {
            if (state is PinnedConversationsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PinnedConversationsLoaded) {
              final conversations = state.conversations;
              if (conversations.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return GestureDetector(
                      onTap: (){
                        context.read<DrummAudioBloc>().add(
                          StartOrSwitchChannelEvent(
                            appId: DrummConstants.appId,
                            token: DrummConstants.generateAgoraToken(drummerState.drummerEntity!.rid.toString(), conversation.conversationId??""),
                            channelName: conversation.conversationId??"",
                            uid: drummerState.drummerEntity!.rid??1234,
                            isMuted: false,
                          ),
                        );
                        _showCallBottomSheet(context,conversation);
                      },
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: DrummTheme.primaryItemColor(context),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              conversation.title ?? 'No Title',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${(drummerState.drummerEntity!.uid == conversation.startedBy)?"You Pinned at: ":"Pinned at:"} ${CoreUtils.getFormattedTime(conversation.pinnedAt!.toDate())}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is PinnedConversationsError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const SizedBox.shrink();
          },
        );
        }

        return SizedBox.shrink();
      }
    );
  }

  void _showCallBottomSheet(BuildContext context,ConversationEntity conversation) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DrummAudioBottomSheet(channelName:conversation.conversationId??"");
      },
      isScrollControlled: true, // optional for a full-screen bottom sheet
    );
  }
}
