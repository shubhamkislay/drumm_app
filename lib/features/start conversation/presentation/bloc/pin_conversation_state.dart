import 'package:equatable/equatable.dart';

abstract class PinConversationState extends Equatable {
  const PinConversationState();

  @override
  List<Object?> get props => [];
}

class PinConversationInitial extends PinConversationState {}

class PinConversationLoading extends PinConversationState {}

class PinConversationSuccess extends PinConversationState {}

class PinConversationFailure extends PinConversationState {
  final String error;

  const PinConversationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
