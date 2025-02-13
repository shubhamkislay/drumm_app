abstract class DrummAudioEvent {}

/// Event to initialize, join, and subscribe to channel events.
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

/// Event to leave the channel.
class LeaveDrummChannelEvent extends DrummAudioEvent {}

/// Event to mute/unmute local audio.
class MuteDrummAudioEvent extends DrummAudioEvent {
  final bool muted;
  final String channelName;
  MuteDrummAudioEvent(this.muted, this.channelName);
}

/// Event fired internally when a remote user joins.
class DrummRemoteUserJoinedEvent extends DrummAudioEvent {
  final int uid;
  final String channelName;
  DrummRemoteUserJoinedEvent(this.uid, this.channelName);
}

class DrummRemoteUserLeftEvent extends DrummAudioEvent {
  final int uid;
  final String channelName;
  DrummRemoteUserLeftEvent(this.uid, this.channelName);
}

/// Event fired internally when the local user joins.
class DrummChannelJoined extends DrummAudioEvent {
  final String channelName;
  DrummChannelJoined(this.channelName);
}

/// Event fired internally when a remote user is muted.
class DrummRemoteUserMutedEvent extends DrummAudioEvent {
  final int uid;
  final bool isMuted;
  final String channelName;
  DrummRemoteUserMutedEvent(this.uid, this.isMuted, this.channelName);
}

/// Event fired internally when a remote user's talking status changes.
class DrummRemoteUserTalkingEvent extends DrummAudioEvent {
  final int uid;
  final bool isTalking;
  final String channelName;
  DrummRemoteUserTalkingEvent(this.uid, this.isTalking, this.channelName);
}

/// Event to start or switch channels.
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
