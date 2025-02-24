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
import 'package:drumm_app/features/start%20conversation/presentation/widgets/pinned_conversation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PinnedConversationsWidget extends StatelessWidget {
  const PinnedConversationsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dispatch the event to load pinned conversations when the widget is built.
    context.read<PinnedConversationsBloc>().add(LoadPinnedConversationsEvent());

    return BlocBuilder<RemoteDrummerBloc, RemoteDrummerState>(
        builder: (context, drummerState) {
      if (drummerState is RemoteDrummerDone) {
        return BlocBuilder<PinnedConversationsBloc, PinnedConversationsState>(
          builder: (context, state) {
            if (state is PinnedConversationsLoading) {
              return const SizedBox.shrink();
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
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return PinnedConversationItem(
                      conversation: conversation,
                      drummerEntity: drummerState.drummerEntity!,
                      onTap: () {
                        context.read<DrummAudioBloc>().add(
                              StartOrSwitchChannelEvent(
                                appId: DrummConstants.appId,
                                conversation: conversation,
                                token: DrummConstants.generateAgoraToken(
                                    drummerState.drummerEntity!.rid.toString(),
                                    conversation.conversationId ?? ""),
                                channelName: conversation.conversationId ?? "",
                                uid: drummerState.drummerEntity!.rid ?? 1234,
                                isMuted: false,
                              ),
                            );
                        _showCallBottomSheet(context, conversation);
                      },
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
    });
  }

  void _showCallBottomSheet(
      BuildContext context, ConversationEntity conversation) {
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
