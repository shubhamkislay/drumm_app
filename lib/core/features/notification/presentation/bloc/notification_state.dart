import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {}

class NotificationFailure extends NotificationState {
  final String error;

  const NotificationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ForegroundNotificationLoaded extends NotificationState {
  final ConversationEntity conversation;
  const ForegroundNotificationLoaded({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

class BackgroundNotificationLoaded extends NotificationState {
  final ConversationEntity conversation;
  const BackgroundNotificationLoaded({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}