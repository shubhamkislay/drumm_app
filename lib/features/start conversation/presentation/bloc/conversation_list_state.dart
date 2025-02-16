import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class ConversationListState extends Equatable {
  const ConversationListState();

  @override
  List<Object?> get props => [];
}

class ConversationListInitial extends ConversationListState {}

class ConversationListLoading extends ConversationListState {}

class ConversationListLoaded extends ConversationListState {
  final List<ConversationEntity> conversations;

  const ConversationListLoaded({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class ConversationListError extends ConversationListState {
  final String message;

  const ConversationListError({required this.message});

  @override
  List<Object?> get props => [message];
}
