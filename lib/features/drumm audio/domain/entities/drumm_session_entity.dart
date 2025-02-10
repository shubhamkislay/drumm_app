// domain/entities/call_session_entity.dart

class DrummSessionEntity {
  final String channelName;
  final int userId;
  final bool isMuted;

  DrummSessionEntity({
    required this.channelName,
    required this.userId,
    required this.isMuted,
  });
}
