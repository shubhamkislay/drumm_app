import 'package:equatable/equatable.dart';

abstract class ConversationListEvent extends Equatable {
  const ConversationListEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends ConversationListEvent {}
