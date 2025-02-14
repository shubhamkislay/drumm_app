abstract class DrummAudioState {
  final String channelName;

  final List<int> remoteUserIds;

  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioState(this.channelName, this.remoteUserIds, this.talkingStatus, this.muteStatus);
}

class DrummAudioInitial extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioInitial(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioLoading extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioLoading(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

/// When joined, we now persist the remote user IDs and their talking status.
class DrummAudioJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioJoined({
    required this.channelName,
    this.remoteUserIds = const [],
    this.talkingStatus = const {},
    this.muteStatus = const {},
  }) : super(channelName, remoteUserIds,talkingStatus,muteStatus);
}

class DrummAudioLeft extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioLeft(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioLocalUserJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioLocalUserJoined(this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioRemoteUserJoined extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioRemoteUserJoined(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioRemoteUserLeft extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioRemoteUserLeft(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioRemoteUserMuted extends DrummAudioState {
  final int uid;
  final bool isMuted;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioRemoteUserMuted(this.uid, this.isMuted, this.channelName,this.remoteUserIds,this.talkingStatus, { this.muteStatus = const {},}) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioRemoteUserTalking extends DrummAudioState {
  final int uid;
  final bool isTalking;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioRemoteUserTalking(this.uid, this.isTalking, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus) : super(channelName, remoteUserIds,talkingStatus, muteStatus);
}

class DrummAudioError extends DrummAudioState {
  final String message;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioError(this.message,this.remoteUserIds,this.talkingStatus,this.muteStatus) : super('',remoteUserIds,talkingStatus,muteStatus);
}
