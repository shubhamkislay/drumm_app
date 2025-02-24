import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_state.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/conversation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationHorizontalList extends StatelessWidget {
  final DrummerEntity drummerEntity;
  const ConversationHorizontalList({Key? key, required this.drummerEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dispatch the event to load conversations when the widget builds.
    context.read<ConversationListBloc>().add(LoadConversationsEvent());

    return BlocBuilder<ConversationListBloc, ConversationListState>(
      builder: (context, state) {
        if (state is ConversationListLoading) {
          return const SizedBox.shrink();
        } else if (state is ConversationListLoaded) {
          final conversations = state.conversations;
          if (conversations.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 100, // Adjust based on your design
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: conversations.length,
              padding: EdgeInsets.symmetric(horizontal: 6),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationCard(conversation: conversation,drummerEntity: drummerEntity,);
              },
            ),
          );
        } else if (state is ConversationListError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}


