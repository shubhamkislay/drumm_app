// domain/repositories/i_drumm_repository.dart


import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_remote_event.dart';

/// Abstraction for Drumm audio-related operations
abstract class IDrummRepository {
  Future<void> initializeEngine(String appId);

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isMuted,
  });

  Future<void> leaveChannel();

  Future<void> muteLocalAudio(bool muted);

  Stream<DrummRemoteEvent> getRemoteEvents();

  Future<void> disposeEngine();
}
