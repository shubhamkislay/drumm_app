import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/drumm audio/data/data_sources/drumm_remote_event.dart';
import 'package:drumm_app/features/drumm audio/domain/repository/drumm_repository.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/join_drumm_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/leave_drumm_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/listen_drumm_events_usecase.dart';
import 'package:drumm_app/features/drumm audio/domain/usecases/mute_drumm_audio_usecase.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'drumm_audio_event.dart';
import 'drumm_audio_state.dart';

class DrummAudioBloc extends Bloc<DrummAudioEvent, DrummAudioState> {
  final IDrummRepository repository;
  final JoinDrummUseCase joinUseCase;
  final LeaveDrummUseCase leaveUseCase;
  final MuteDrummAudioUseCase muteUseCase;
  final ListenDrummEventsUseCase listenUseCase;
  StreamSubscription<DrummRemoteEvent>? _drummEventSub;

  // Persistent lists to store remote user IDs and their talking statuses.
  final List<int> _remoteUserIds = [];
  final Map<int, bool> _talkingStatus = {};
  final Map<int, bool> _muteStatus = {};

  DrummAudioBloc({
    required this.repository,
    required this.joinUseCase,
    required this.leaveUseCase,
    required this.muteUseCase,
    required this.listenUseCase,
  }) : super(DrummAudioInitial('',[],{},{},ConversationEntity())) {
    on<StartOrSwitchChannelEvent>(_onStartOrSwitchChannelEvent);
    on<LeaveDrummChannelEvent>(_onLeaveChannel);
    on<MuteDrummAudioEvent>(_onMuteAudio);

    // When a remote user joins, add them to the list and emit an updated joined state.
    on<DrummRemoteUserJoinedEvent>((event, emit) {
      if (!_remoteUserIds.contains(event.uid)) {
        _remoteUserIds.add(event.uid);
      }
      emit(DrummAudioRemoteUserJoined(
        event.uid,
        event.channelName,
        List.from(_remoteUserIds),
        Map.from(_talkingStatus),
        Map.from(_muteStatus),
        event.conversation
      ));
    });

    on<DrummRemoteUserLeftEvent>((event, emit) {
      if (_remoteUserIds.contains(event.uid)) {
        _remoteUserIds.remove(event.uid);
      }
      emit(DrummAudioRemoteUserLeft(
        event.uid,
        event.channelName,
        List.from(_remoteUserIds),
        Map.from(_talkingStatus),
        Map.from(_muteStatus),
        event.conversation
      ));
    });

    // When a remote user is muted, emit a muted state.
    on<DrummRemoteUserMutedEvent>((event, emit) {
      _muteStatus[event.uid] = event.isMuted;
      emit(DrummAudioRemoteUserMuted(event.uid, event.isMuted, event.channelName,[],{},event.conversation,muteStatus: Map.from(_muteStatus)));
    });

    // When a remote user's talking status changes, update the map and re-emit the joined state.
    on<DrummRemoteUserTalkingEvent>((event, emit) {
      _talkingStatus[event.uid] = event.isTalking;
      emit(DrummAudioJoined(
        event.channelName,
       List.from(_remoteUserIds),
       Map.from(_talkingStatus),
       Map.from(_muteStatus),
        event.conversation
      ));
    });

    // When the local user joins, add them (using 0 as local uid) and emit updated state.
    on<DrummChannelJoined>((event, emit) {
      if (!_remoteUserIds.contains(event.uid)) {
        _remoteUserIds.add(event.uid);
      }
      emit(DrummAudioJoined(
          event.channelName,
          List.from(_remoteUserIds),
          Map.from(_talkingStatus),
          Map.from(_muteStatus),
          event.conversation
      ));
      print("DrummChannelJoined event received.");
    });
  }

  Future<void> _onStartOrSwitchChannelEvent(
      StartOrSwitchChannelEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    try {
      // If already in a channel (and not in initial, left, or error state)
      if (state is! DrummAudioInitial &&
          state is! DrummAudioLeft &&
          state is! DrummAudioError) {
        final currentChannel = state.channelName;
        print("Current Channel: $currentChannel");
        print("Event Channel: ${event.channelName}");
        if (currentChannel == event.channelName) {
          // If it's the same channel, re-emit the joined state with the persisted list.
          emit(DrummAudioJoined(
              event.channelName,
              List.from(_remoteUserIds),
              Map.from(_talkingStatus),
              Map.from(_muteStatus),
              event.conversation
          ));
          return;
        } else {
          // If switching channels, leave the current channel and clear the persistent lists.
          print("Switching channel");
          await leaveUseCase.call();
          _remoteUserIds.clear();
          _talkingStatus.clear();
          _muteStatus.clear();
        }
      } else {
        print("State is: $state");
      }

      // 1) Initialize the engine.
      await repository.initializeEngine(event.appId);

      // 2) Subscribe to remote events if not already subscribed.
      _drummEventSub ??= listenUseCase.call().listen((drummEvent) {
        //print("Listening to drumm Events");
        if (drummEvent is DrummRemoteUserJoined) {
          add(DrummRemoteUserJoinedEvent(drummEvent.uid, event.channelName,event.conversation));
        } else if (drummEvent is DrummRemoteUserMuted) {
          add(DrummRemoteUserMutedEvent(drummEvent.uid, drummEvent.isMuted, event.channelName,event.conversation));
        } else if (drummEvent is DrummRemoteUserTalking) {
          add(DrummRemoteUserTalkingEvent(drummEvent.uid, drummEvent.isTalking, event.channelName,event.conversation));
        } else if (drummEvent is DrummLocalUserJoined) {
          print("drummEvent is DrummLocalUserJoined");
          add(DrummChannelJoined(event.channelName,drummEvent.uid,event.conversation));
        } else if (drummEvent is DrummRemoteUserLeft) {
          add(DrummRemoteUserLeftEvent(drummEvent.uid, event.channelName,event.conversation));
        }
      });

      // 3) Join the new channel.
      await joinUseCase.call(
        token: event.token,
        channelName: event.channelName,
        uid: event.uid,
        isMuted: event.isMuted,
      );

      // 4) Emit the joined state (the persistent lists will be updated as events arrive).
      emit(DrummAudioJoined(
          event.channelName,
          List.from(_remoteUserIds),
          Map.from(_talkingStatus),
          Map.from(_muteStatus),
          event.conversation
      ));
    } catch (e) {
      emit(DrummAudioError('Failed to start or switch channel: $e',[],{},{},event.conversation));
    }
  }

  Future<void> _onLeaveChannel(
      LeaveDrummChannelEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    emit(DrummAudioLoading('',[],{},{},ConversationEntity()));
    try {
      await leaveUseCase.call();
      // Clear persistent lists upon leaving.
      _remoteUserIds.clear();
      _talkingStatus.clear();
      _muteStatus.clear();
      emit(DrummAudioLeft('',[],{},{},ConversationEntity()));
    } catch (e) {
      emit(DrummAudioError('Failed to leave channel: $e',[],{},{},ConversationEntity()));
    }
  }

  Future<void> _onMuteAudio(
      MuteDrummAudioEvent event,
      Emitter<DrummAudioState> emit,
      ) async {
    try {
      await muteUseCase.call(event.muted);
    } catch (e) {
      emit(DrummAudioError('Failed to mute/unmute: $e',[],{},{},event.conversation));
    }
  }

  @override
  Future<void> close() {
    _drummEventSub?.cancel();
    return super.close();
  }
}
