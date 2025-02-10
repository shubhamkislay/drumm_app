// data/repositories/drumm_audio_repository_impl.dart


import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_audio_service.dart';
import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_remote_event.dart';
import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';

class DrummAudioRepositoryImpl implements IDrummRepository {
  final DrummAudioService drummAudioService;

  DrummAudioRepositoryImpl({required this.drummAudioService});

  @override
  Future<void> initializeEngine(String appId) {
    return drummAudioService.initialize(appId);
  }

  @override
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isMuted,
  }) {
    return drummAudioService.joinChannel(
      token: token,
      channelName: channelName,
      uid: uid,
      isMuted: isMuted,
    );
  }

  @override
  Future<void> leaveChannel() {
    return drummAudioService.leaveChannel();
  }

  @override
  Future<void> muteLocalAudio(bool muted) {
    return drummAudioService.muteLocalAudio(muted);
  }

  @override
  Stream<DrummRemoteEvent> getRemoteEvents() {
    return drummAudioService.remoteEventsStream;
  }

  @override
  Future<void> disposeEngine() {
    return drummAudioService.dispose();
  }
}
