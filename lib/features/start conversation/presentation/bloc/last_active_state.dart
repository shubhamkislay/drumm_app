import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LastActiveState extends Equatable {
  const LastActiveState();

  @override
  List<Object?> get props => [];
}

class LastActiveInitial extends LastActiveState {}

class LastActiveUpdated extends LastActiveState {
  final Timestamp lastActive;


  const LastActiveUpdated({required this.lastActive});

  @override
  List<Object?> get props => [lastActive];
}

class LastActiveError extends LastActiveState {
  final String message;

  const LastActiveError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LastActiveStopped extends LastActiveState {}
