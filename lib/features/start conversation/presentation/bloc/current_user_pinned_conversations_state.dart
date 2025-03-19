import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class CurrentUserPinnedConversationsState extends Equatable {
  const CurrentUserPinnedConversationsState();

  @override
  List<Object?> get props => [];
}

class PinnedConversationsInitial extends CurrentUserPinnedConversationsState {}

class PinnedConversationsLoading extends CurrentUserPinnedConversationsState {}

class UnpinningConversation extends CurrentUserPinnedConversationsState {}

class ConversationUnpinned extends CurrentUserPinnedConversationsState {}

class UnableToUnpinConversation extends CurrentUserPinnedConversationsState {
  final String error;

  const UnableToUnpinConversation({required this.error});

  @override
  List<Object?> get props => [error];
}

class PinnedConversationsLoaded extends CurrentUserPinnedConversationsState {
  final List<ConversationEntity> conversations;

  const PinnedConversationsLoaded({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class CurrentUserPinnedConversationsLoaded extends CurrentUserPinnedConversationsState {
  final List<ConversationEntity> conversations;

  const CurrentUserPinnedConversationsLoaded({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class PinnedConversationsError extends CurrentUserPinnedConversationsState {
  final String error;

  const PinnedConversationsError({required this.error});

  @override
  List<Object?> get props => [error];
}
