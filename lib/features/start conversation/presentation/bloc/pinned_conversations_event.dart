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
