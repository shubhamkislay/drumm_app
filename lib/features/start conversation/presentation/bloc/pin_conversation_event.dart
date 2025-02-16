import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class PinConversationEvent extends Equatable {
  const PinConversationEvent();

  @override
  List<Object?> get props => [];
}

class CreatePinConversationEvent extends PinConversationEvent {
  final ConversationEntity conversation;

  const CreatePinConversationEvent({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}
