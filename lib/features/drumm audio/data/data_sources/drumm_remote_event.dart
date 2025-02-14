/// Abstract parent for any Drumm remote events
abstract class DrummRemoteEvent {}

/// Concrete event types
class DrummRemoteUserJoined extends DrummRemoteEvent {
  final int uid;
  DrummRemoteUserJoined(this.uid);
}

class DrummRemoteUserLeft extends DrummRemoteEvent {
  final int uid;
  DrummRemoteUserLeft(this.uid);
}

class DrummLocalUserJoined extends DrummRemoteEvent {
  final int uid;
  DrummLocalUserJoined(this.uid);
}

class DrummRemoteUserMuted extends DrummRemoteEvent {
  final int uid;
  final bool isMuted;
  DrummRemoteUserMuted({
    required this.uid,
    required this.isMuted,
  });
}

class DrummRemoteUserTalking extends DrummRemoteEvent {
  final int uid;
  final bool isTalking;
  DrummRemoteUserTalking({
    required this.uid,
    required this.isTalking,
  });
}
