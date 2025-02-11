// data/datasources/drumm_audio_remote_data_source.dart

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_remote_event.dart';


/// This is our service integrating with Agora.
/// You can rename fields/methods as you see fit.
class DrummAudioService {
  final RtcEngine _engine = createAgoraRtcEngine();

  // Broadcast so multiple subscribers can listen if needed.
  final StreamController<DrummRemoteEvent> _remoteEventsController =
  StreamController<DrummRemoteEvent>.broadcast();

  /// Expose the stream of remote events
  Stream<DrummRemoteEvent> get remoteEventsStream =>
      _remoteEventsController.stream;

  /// Initialize the Drumm Audio (Agora) engine
  Future<void> initialize(String appId) async {
    await _engine.initialize(
      RtcEngineContext(appId: appId),
    );
    print("Agora Engine is initialised");

    RtcEngineEventHandler rtcEngineEventHandler = RtcEngineEventHandler(
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("User $remoteUid has joined");
        _remoteEventsController.add(
          DrummRemoteUserJoined(remoteUid),
        );
      },
      onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
        print("Mic Mute is $muted");
        _remoteEventsController.add(
          DrummRemoteUserMuted(uid: remoteUid, isMuted: muted),
        );
      },
      onAudioVolumeIndication: (RtcConnection connection,
          List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
        for (final speaker in speakers) {
          if (speaker.uid != null) {
            // If volume is above 50, assume user is talking
            bool isTalking = speaker.volume != null && speaker.volume! > 50;
            if(isTalking)
              print("User is talking");
            _remoteEventsController.add(
              DrummRemoteUserTalking(uid: speaker.uid!, isTalking: isTalking),
            );
          }
        }
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed){
        _remoteEventsController.add(DrummLocalUserJoined());
      },
    );

    _engine.muteLocalAudioStream(false);
    _engine.enableAudioVolumeIndication(
        interval: 300, smooth: 6, reportVad: true);
    _engine.registerEventHandler(rtcEngineEventHandler);

    await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard);
    print("Audio Profile is set");
  }

  /// Join a channel with a token, channel name, userID, and muted state
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isMuted,
  }) async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Mute/unmute on join
    await _engine.muteLocalAudioStream(isMuted);
  }

  /// Leave the current channel
  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  /// Mute/unmute local audio
  Future<void> muteLocalAudio(bool muted) async {
    await _engine.muteLocalAudioStream(muted);
  }

  /// Release resources and close event streams
  Future<void> dispose() async {
    await _engine.release();
    await _remoteEventsController.close();
  }
}
