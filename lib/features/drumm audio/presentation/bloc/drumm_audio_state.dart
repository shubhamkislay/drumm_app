// presentation/bloc/drumm_audio/drumm_audio_state.dart

abstract class DrummAudioState {}

class DrummAudioInitial extends DrummAudioState {}

class DrummAudioLoading extends DrummAudioState {}

/// User has successfully joined (engine is initialized, events are streaming)
// Keep a reference to the current channelName if joined
class DrummAudioJoined extends DrummAudioState {
  final String channelName;
  DrummAudioJoined(this.channelName);
}

class DrummAudioLeft extends DrummAudioState {}

class DrummAudioRemoteUserJoined extends DrummAudioState {
  final int uid;
  DrummAudioRemoteUserJoined(this.uid);
}

class DrummAudioRemoteUserMuted extends DrummAudioState {
  final int uid;
  final bool isMuted;
  DrummAudioRemoteUserMuted(this.uid, this.isMuted);
}

class DrummAudioRemoteUserTalking extends DrummAudioState {
  final int uid;
  final bool isTalking;
  DrummAudioRemoteUserTalking(this.uid, this.isTalking);
}

class DrummAudioError extends DrummAudioState {
  final String message;
  DrummAudioError(this.message);
}



