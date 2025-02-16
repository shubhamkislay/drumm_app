import 'package:equatable/equatable.dart';

abstract class LastActiveEvent extends Equatable {
  const LastActiveEvent();

  @override
  List<Object?> get props => [];
}

class StartUpdatingLastActive extends LastActiveEvent {

  final String conversationId;
  StartUpdatingLastActive(this.conversationId);
}

class StopUpdatingLastActive extends LastActiveEvent {}
