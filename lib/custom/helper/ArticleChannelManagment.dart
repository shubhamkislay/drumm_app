import 'dart:convert';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// Step 2: Create a class to manage the voice chat channels
class AgoraVoiceService {
  static final AgoraVoiceService _instance = AgoraVoiceService._internal();

  bool isTokenExpiring = false;

  bool _isJoined = false;
  static const String appId = "0608d9da67a9458db263b255c8f30778";
  factory AgoraVoiceService() => _instance;
  int uid  = new Random().nextInt(1000000001) + 1;

  String serverUrl =
      "https://agora-token-service-production-d901.up.railway.app";
  String token =
      "007eJxTYDi2XDj2UGSig8f0DawrP32q/z7PTbVP3LeBb22bvmmZ9n4FBgMzA4sUy5REM/NESxNTi5QkIzPjJCNT02SLNGMDc3OLZ+GLkxsCGRk2OLxjYIRCEJ+boSA/Pyc5IzEvLzWHgQEA8RwhmQ==";

  int tokenRole = 1;

  String channelName = "";


  RtcEngine? _rtcEngine;
  bool _isConnected = false;

  AgoraVoiceService._internal();

  // Initialize Agora Voice SDK
  Future<void> initialize() async {
    // Initialize and configure Agora Voice SDK
    await [Permission.microphone].request();
    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine?.initialize(const RtcEngineContext(appId: appId));

    _rtcEngine?.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
          debugPrint("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $msg");
          debugPrint("ERROR!!!!!!!!!!Reason!!!! $err");
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint("onTokenPrivilegeWillExpire called");
          print('Token expiring');
          isTokenExpiring = true;
          fetchToken(uid, channelName, tokenRole);

        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("onJoinChannelSuccess called");
          _isJoined = true;
          print("Local user uid:${connection.localUid} joined the channel");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid:$remoteUid left the channel");
        },
      ),
    );

  }

  bool get isConnected => _isConnected;

  Future<void> fetchToken(int uid, String channelName, int tokenRole) async {
    // Prepare the Url
    String url =
        '$serverUrl/rtc/$channelName/${tokenRole.toString()}/uid/${uid.toString()}';
    debugPrint('Url: $url');
    // Send the request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      debugPrint('Token Received: $newToken');
      // Use the token to join a channel or renew an expiring token
      setToken(newToken);
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  void setToken(String newToken) async {
    token = newToken;

    if (isTokenExpiring) {
      // Renew the token
      _rtcEngine?.renewToken(token);
      isTokenExpiring = false;
      print("Token renewed");
    } else {
      // Join a channel.
      debugPrint("setToken");
      print("Token received setToken, joining a channel...");

    }
  }

  // Join a voice chat channel
  Future<void> joinChannel(String channelName) async {
    if (_isConnected) return; // Already connected

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _rtcEngine?.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
    _isConnected = true;
  }

  // Leave the voice chat channel
  Future<void> leaveChannel() async {
    if (!_isConnected) return; // Not connected

    await _rtcEngine!.leaveChannel();
    _isConnected = false;
  }

  // Clean up resources
  Future<void> dispose() async {
    //await _rtcEngine?.destroy();
    _rtcEngine = null;
  }
}

// Step 4: Create a globally accessible instance of AgoraVoiceService
// final agoraVoiceService = AgoraVoiceService();
//
// // Step 5: Handle page navigation and lifecycle events
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     // Step 3: Join the channel when the home page is initialized
//     agoraVoiceService.joinChannel('my_channel');
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance!.removeObserver(this);
//     // Step 7: Leave the channel and clean up resources when the home page is disposed
//     agoraVoiceService.leaveChannel();
//     agoraVoiceService.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     // Step 6: Handle app lifecycle state changes
//     switch (state) {
//       case AppLifecycleState.resumed:
//       // Rejoin the channel when the app is restored from the background
//         agoraVoiceService.joinChannel('my_channel');
//         break;
//       case AppLifecycleState.paused:
//       // Leave the channel when the app is sent to the background
//         agoraVoiceService.leaveChannel();
//         break;
//       default:
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Page'),
//       ),
//       body: Center(
//         child: Text('Welcome to the Home Page'),
//       ),
//     );
//   }
// }
