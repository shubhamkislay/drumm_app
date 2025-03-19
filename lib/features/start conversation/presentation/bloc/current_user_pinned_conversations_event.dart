import 'package:equatable/equatable.dart';

abstract class CurrentUserPinnedConversationsEvent extends Equatable {
  const CurrentUserPinnedConversationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPinnedConversationsCurrentUserEvent extends CurrentUserPinnedConversationsEvent {
  final bool onlyCurrentUser;
  const LoadPinnedConversationsCurrentUserEvent({required this.onlyCurrentUser});
}

class CurrentUserLoadPinnedConversationsEvent extends CurrentUserPinnedConversationsEvent {}

class UnpinConversationCurrentUserEvent extends CurrentUserPinnedConversationsEvent {
  final String conversationId;
  final bool onlyCurrentUser;
  const UnpinConversationCurrentUserEvent({required this.conversationId, required this.onlyCurrentUser});
}

