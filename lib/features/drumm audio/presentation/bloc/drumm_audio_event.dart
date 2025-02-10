// presentation/bloc/drumm_audio/drumm_audio_event.dart

abstract class DrummAudioEvent {}

/// A single event to do everything:
/// 1) Initialize engine
/// 2) Subscribe to remote events
/// 3) Join the channel
class InitializeJoinListenDrummEvent extends DrummAudioEvent {
  final String appId;
  final String token;
  final String channelName;
  final int uid;
  final bool isMuted;

  InitializeJoinListenDrummEvent({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.isMuted,
  });
}

/// Leave channel
class LeaveDrummChannelEvent extends DrummAudioEvent {}

/// Mute local audio
class MuteDrummAudioEvent extends DrummAudioEvent {
  final bool muted;
  MuteDrummAudioEvent(this.muted);
}

/// These events are triggered **internally** when we get updates
/// from the DrummAudioService's stream:
class DrummRemoteUserJoinedEvent extends DrummAudioEvent {
  final int uid;
  DrummRemoteUserJoinedEvent(this.uid);
}


class DrummChannelJoined extends DrummAudioEvent {
  DrummChannelJoined();
}

class DrummRemoteUserMutedEvent extends DrummAudioEvent {
  final int uid;
  final bool isMuted;
  DrummRemoteUserMutedEvent(this.uid, this.isMuted);
}

class DrummRemoteUserTalkingEvent extends DrummAudioEvent {
  final int uid;
  final bool isTalking;
  DrummRemoteUserTalkingEvent(this.uid, this.isTalking);
}

class StartOrSwitchChannelEvent extends DrummAudioEvent {
  final String appId;
  final String token;
  final String channelName;
  final int uid;
  final bool isMuted;

  StartOrSwitchChannelEvent({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.isMuted,
  });
}