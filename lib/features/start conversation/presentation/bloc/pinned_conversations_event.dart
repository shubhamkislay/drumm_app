import 'package:equatable/equatable.dart';

abstract class PinnedConversationsEvent extends Equatable {
  const PinnedConversationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPinnedConversationsEvent extends PinnedConversationsEvent {}
