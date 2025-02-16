import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class PinnedConversationsState extends Equatable {
  const PinnedConversationsState();

  @override
  List<Object?> get props => [];
}

class PinnedConversationsInitial extends PinnedConversationsState {}

class PinnedConversationsLoading extends PinnedConversationsState {}

class PinnedConversationsLoaded extends PinnedConversationsState {
  final List<ConversationEntity> conversations;

  const PinnedConversationsLoaded({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class PinnedConversationsError extends PinnedConversationsState {
  final String error;

  const PinnedConversationsError({required this.error});

  @override
  List<Object?> get props => [error];
}
