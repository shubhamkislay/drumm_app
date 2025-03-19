import 'package:equatable/equatable.dart';

abstract class PinnedConversationsEvent extends Equatable {
  const PinnedConversationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPinnedConversationsEvent extends PinnedConversationsEvent {
  final bool onlyCurrentUser;
  const LoadPinnedConversationsEvent({required this.onlyCurrentUser});
}

class CurrentUserLoadPinnedConversationsEvent extends PinnedConversationsEvent {}

class UnpinConversationEvent extends PinnedConversationsEvent {
  final String conversationId;
  final bool onlyCurrentUser;
  const UnpinConversationEvent({required this.conversationId, required this.onlyCurrentUser});
}

