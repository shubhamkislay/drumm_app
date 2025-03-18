import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_event.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_state.dart';
import 'package:drumm_app/features/start%20conversation/presentation/pages/join_conversation_confirmation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/pinned_conversation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PinnedConversationsWidget extends StatefulWidget {

  const PinnedConversationsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PinnedConversationsWidget> createState() => _PinnedConversationsWidgetState();
}

class _PinnedConversationsWidgetState extends State<PinnedConversationsWidget> {
  @override
  Widget build(BuildContext context) {
    // Dispatch the event to load pinned conversations when the widget is built.

    return BlocBuilder<RemoteDrummerBloc, RemoteDrummerState>(
        builder: (context, drummerState) {

      if (drummerState is RemoteDrummerDone ||drummerState is  RefreshedDrummer) {
        context.read<PinnedConversationsBloc>().add(LoadPinnedConversationsEvent());
        print("Calling Pinned Conversation");
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
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: conversations.length,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return PinnedConversationItem(
                      conversation: conversation,
                      drummerEntity: drummerState.drummerEntity!,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // enables custom height sizing
                          backgroundColor:
                          Colors.transparent, // for rounded corners effect
                          builder: (BuildContext context) {
                            return JoinConversationConfirmation(
                              sendNotification:true,
                              conversation: conversation,
                              drummerEntity:
                              drummerState.drummerEntity ?? DrummerEntity(),
                            );
                          },
                        );

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
}
