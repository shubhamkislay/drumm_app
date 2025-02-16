import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class CreateConversationEvent extends ConversationEvent {
  final ConversationEntity conversation;

  const CreateConversationEvent({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}


