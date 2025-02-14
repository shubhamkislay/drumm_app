import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_remote_event.dart';

class DrummAudioService {
  final RtcEngine _engine = createAgoraRtcEngine();
  final StreamController<DrummRemoteEvent> _remoteEventsController =
      StreamController<DrummRemoteEvent>.broadcast();

  // Flag to ensure initialization only happens once.
  bool _isInitialized = false;
  int localUid = 0;

  /// Expose the stream of remote events.
  Stream<DrummRemoteEvent> get remoteEventsStream =>
      _remoteEventsController.stream;

  /// Initialize the Agora engine and register the event handler if not already done.
  Future<void> initialize(String appId) async {
    if (!_isInitialized) {
      await _engine.initialize(RtcEngineContext(appId: appId));
      print("Agora Engine is initialized");

      RtcEngineEventHandler rtcEngineEventHandler = RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("User $remoteUid has joined");
          _remoteEventsController.add(DrummRemoteUserJoined(remoteUid));
        },
        onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
          print("User $remoteUid mute status: $muted");
          _remoteEventsController
              .add(DrummRemoteUserMuted(uid: remoteUid, isMuted: muted));
        },
        onAudioVolumeIndication: (
          RtcConnection connection,
          List<AudioVolumeInfo> speakers,
          int speakerNumber,
          int totalVolume,
        ) {
          for (final speaker in speakers) {
            if (speaker.uid != null) {
              bool isTalking = (speaker.volume != null && speaker.volume! > 50);
              _remoteEventsController.add(
                DrummRemoteUserTalking(uid: (speaker.uid!=0)?speaker.uid!:localUid, isTalking: isTalking),
              );
            }
          }
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("onJoinChannelSuccess called");
          _remoteEventsController.add(DrummLocalUserJoined(localUid));
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _remoteEventsController.add(DrummRemoteUserLeft(remoteUid));
        },
      );

      // Register the event handler only once.
      _engine.registerEventHandler(rtcEngineEventHandler);

      // Additional engine configuration.
      await _engine.muteLocalAudioStream(false);
      await _engine.enableAudioVolumeIndication(
        interval: 300,
        smooth: 6,
        reportVad: true,
      );
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard,
      );
      print("Audio profile is set");

      _isInitialized = true;
    } else {
      print("Engine already initialized; skipping reinitialization.");
    }
  }

  /// Join a channel with the provided token, channel name, user ID, and muted state.
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isMuted,
  }) async {
    localUid = uid;
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    await _engine.muteLocalAudioStream(isMuted);
  }

  /// Leave the current channel.
  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  /// Mute or unmute the local audio.
  Future<void> muteLocalAudio(bool muted) async {
    print("${(muted) ? 'Muting' : 'Un-muting'} local audio");
    await _engine.muteLocalAudioStream(muted);
    _remoteEventsController
        .add(DrummRemoteUserMuted(uid: localUid, isMuted: muted));
  }

  /// Dispose the engine and close the event stream.
  Future<void> dispose() async {
    await _engine.release();
    await _remoteEventsController.close();
  }
}
