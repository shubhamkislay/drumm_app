import 'package:equatable/equatable.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationSuccess extends ConversationState {}

class ConversationFailure extends ConversationState {
  final String error;

  const ConversationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
