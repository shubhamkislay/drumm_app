// drumm_audio_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/drumm audio/data/data_sources/drumm_remote_event.dart';
import 'package:drumm_app/features/drumm audio/domain/repository/drumm_repository.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/join_drumm_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/leave_drumm_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/listen_drumm_events_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/mute_drumm_audio_usecase.dart';
import 'drumm_audio_event.dart';
import 'drumm_audio_state.dart';

class DrummAudioBloc extends Bloc<DrummAudioEvent, DrummAudioState> {
  final IDrummRepository repository;
  final JoinDrummUseCase joinUseCase;
  final LeaveDrummUseCase leaveUseCase;
  final MuteDrummAudioUseCase muteUseCase;
  final ListenDrummEventsUseCase listenUseCase;

  StreamSubscription<DrummRemoteEvent>? _drummEventSub;

  DrummAudioBloc({
    required this.repository,
    required this.joinUseCase,
    required this.leaveUseCase,
    required this.muteUseCase,
    required this.listenUseCase,
  }) : super(DrummAudioInitial()) {
    // Use only one event: StartOrSwitchChannelEvent.
    on<StartOrSwitchChannelEvent>(_onStartOrSwitchChannelEvent);
    on<LeaveDrummChannelEvent>(_onLeaveChannel);
    on<MuteDrummAudioEvent>(_onMuteAudio);

    // Handle internal events from the remote events stream.
    on<DrummRemoteUserJoinedEvent>((event, emit) {
      emit(DrummAudioRemoteUserJoined(event.uid));
    });
    on<DrummRemoteUserMutedEvent>((event, emit) {
      emit(DrummAudioRemoteUserMuted(event.uid, event.isMuted));
    });
    on<DrummRemoteUserTalkingEvent>((event, emit) {
      emit(DrummAudioRemoteUserTalking(event.uid, event.isTalking));
    });
    on<DrummChannelJoined>((event, emit) {
      // Optionally, handle a local join event.
      // For instance, you might want to log or update UI.
      print("DrummChannelJoined event received.");
    });
  }

  /// This event handler initializes (if needed), subscribes to remote events, and joins or switches the channel.
  Future<void> _onStartOrSwitchChannelEvent(
      StartOrSwitchChannelEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    emit(DrummAudioLoading());

    try {
      // If already in a channel, check if it's the same.
      if (state is DrummAudioJoined) {
        final currentState = state as DrummAudioJoined;
        final currentChannel = currentState.channelName;

        // If trying to join the same channel, do nothing.
        if (currentChannel == event.channelName) {
          emit(DrummAudioJoined(currentChannel));
          return;
        } else {
          // Leave the current channel if switching.
          await leaveUseCase.call();
        }
      }

      // 1) Initialize the engine.
      await repository.initializeEngine(event.appId);

      // 2) Subscribe to remote events if not already subscribed.
      _drummEventSub ??= listenUseCase.call().listen((drummEvent) {
          print("Listening to drumm Events");
          if (drummEvent is DrummRemoteUserJoined) {
            add(DrummRemoteUserJoinedEvent(drummEvent.uid));
          } else if (drummEvent is DrummRemoteUserMuted) {
            add(DrummRemoteUserMutedEvent(drummEvent.uid, drummEvent.isMuted));
          } else if (drummEvent is DrummRemoteUserTalking) {
            add(DrummRemoteUserTalkingEvent(drummEvent.uid, drummEvent.isTalking));
          } else if (drummEvent is DrummLocalUserJoined) {
            add(DrummChannelJoined());
          }
        });

      // 3) Join the new channel.
      await joinUseCase.call(
        token: event.token,
        channelName: event.channelName,
        uid: event.uid,
        isMuted: event.isMuted,
      );

      // 4) Emit the joined state.
      emit(DrummAudioJoined(event.channelName));
    } catch (e) {
      emit(DrummAudioError('Failed to start or switch channel: $e'));
    }
  }

  Future<void> _onLeaveChannel(
      LeaveDrummChannelEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    emit(DrummAudioLoading());
    try {
      await leaveUseCase.call();
      emit(DrummAudioLeft());
    } catch (e) {
      emit(DrummAudioError('Failed to leave channel: $e'));
    }
  }

  Future<void> _onMuteAudio(
      MuteDrummAudioEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    try {
      await muteUseCase.call(event.muted);
      // Optionally, emit a new state or rely on remote events.
    } catch (e) {
      emit(DrummAudioError('Failed to mute/unmute: $e'));
    }
  }

  @override
  Future<void> close() {
    _drummEventSub?.cancel();
    return super.close();
  }
}
