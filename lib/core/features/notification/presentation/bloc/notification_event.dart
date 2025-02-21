import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class SendNotificationEvent extends NotificationEvent {
  final ConversationEntity conversation;
  final DrummerEntity drummer;

  const SendNotificationEvent({
    required this.conversation,
    required this.drummer,
  });

  @override
  List<Object?> get props => [conversation, drummer];
}

class NotificationReceivedEvent extends NotificationEvent {
  final ConversationEntity conversation;
  const NotificationReceivedEvent({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}
