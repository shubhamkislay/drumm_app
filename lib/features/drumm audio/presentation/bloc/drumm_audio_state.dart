abstract class DrummAudioState {
  final String channelName;

  final List<int> remoteUserIds;

  final Map<int, bool> talkingStatus;
  DrummAudioState(this.channelName, this.remoteUserIds, this.talkingStatus);
}

class DrummAudioInitial extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioInitial(String channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioLoading extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioLoading(String channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

/// When joined, we now persist the remote user IDs and their talking status.
class DrummAudioJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;

  DrummAudioJoined({
    required this.channelName,
    this.remoteUserIds = const [],
    this.talkingStatus = const {},
  }) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioLeft extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioLeft(String channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioLocalUserJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioLocalUserJoined(this.channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioRemoteUserJoined extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioRemoteUserJoined(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioRemoteUserLeft extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioRemoteUserLeft(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioRemoteUserMuted extends DrummAudioState {
  final int uid;
  final bool isMuted;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioRemoteUserMuted(this.uid, this.isMuted, this.channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioRemoteUserTalking extends DrummAudioState {
  final int uid;
  final bool isTalking;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioRemoteUserTalking(this.uid, this.isTalking, this.channelName,this.remoteUserIds,this.talkingStatus) : super(channelName, remoteUserIds,talkingStatus);
}

class DrummAudioError extends DrummAudioState {
  final String message;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  DrummAudioError(this.message,this.remoteUserIds,this.talkingStatus) : super('',remoteUserIds,talkingStatus);
}
