import 'dart:convert';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/theme_constants.dart';

class ArticleChannel extends StatefulWidget {
  final String articleID;
  final double height;
  static String channelID = "";

  ArticleChannel({
    required this.articleID,
    required this.height,
  });

  @override
  _ArticleChannelState createState() => _ArticleChannelState();
}

class _ArticleChannelState extends State<ArticleChannel> {
  late RtcEngine _rtcEngine;
  static const String appId = "0608d9da67a9458db263b255c8f30778";
  late bool _isJoined = false;
  int uid = 11;
  int tokenExpireTime = 45; // Expire time in Seconds.
  bool isTokenExpiring = false;
  String serverUrl =
      "https://agora-token-service-production-d901.up.railway.app";
  String token =
      "007eJxTYDi2XDj2UGSig8f0DawrP32q/z7PTbVP3LeBb22bvmmZ9n4FBgMzA4sUy5REM/NESxNTi5QkIzPjJCNT02SLNGMDc3OLZ+GLkxsCGRk2OLxjYIRCEJ+boSA/Pyc5IzEvLzWHgQEA8RwhmQ==";

  int tokenRole = 1;

  late int _remoteUid;

  bool engineInitialized =
      false; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience;

  @override
  void initState() {
    super.initState();
    //initializeAgora();
  }

  Future<void> initializeAgora() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone].request();
    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine.initialize(const RtcEngineContext(appId: appId));

    print("Engine Initialized");
    engineInitialized = true;

    _rtcEngine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
          debugPrint("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $msg");
          debugPrint("ERROR!!!!!!!!!!Reason!!!! $err");
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint("onTokenPrivilegeWillExpire called");
          print('Token expiring');
          isTokenExpiring = true;
          setState(() {
            // fetch a new token when the current token is about to expire
            fetchToken(uid, widget.articleID, tokenRole);
          });
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("onJoinChannelSuccess called");
          print(widget.articleID);
          print("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
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

    // await _rtcEngine.enableAudio();
    // await _rtcEngine.setAudioProfile(
    //     profile: AudioProfileType.audioProfileDefault);
    ArticleChannel.channelID = widget.articleID;
    join();
  }

  int convertStringToInt(String value) {
    return int.parse(value);
  }

  Future<void> toggleChannelJoinLeave() async {
    if (_isJoined) {
      await _rtcEngine.leaveChannel();
      ArticleChannel.channelID = "";
      //dispose();
      setState(() {
        _isJoined = false;
      });
    } else {
      initializeAgora();
    }
  }

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
      _rtcEngine.renewToken(token);
      isTokenExpiring = false;
      print("Token renewed");
    } else {
      // Join a channel.
      debugPrint("setToken");
      print("Token received setToken, joining a channel...");

      // Set channel options including the client role and channel profile
      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      );

      await _rtcEngine.joinChannel(
        token: token,
        channelId: widget.articleID,
        options: options,
        uid: uid,
      );
    }
  }

  void join() async {
    // debugPrint("join called");
    // await _rtcEngine.startPreview();
    //
    // channelName = widget.callID!; //channelTextController.text;
    // if (channelName.isEmpty) {
    //   print("Enter a channel name");
    //   return;
    // } else {
    //   print("Fetching a token ...");
    // }

    await fetchToken(uid, widget.articleID, tokenRole);
  }

  @override
  void dispose() {
    print("Disposing Article Channel");
    if (engineInitialized) {
      _rtcEngine.release();
      ArticleChannel.channelID = "";
      engineInitialized = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    int randomNumber = random.nextInt(1000000001) + 1;
    print("User RANDOM ID GENERATED $randomNumber");
    uid = randomNumber;
    return RoundedButton(
      height: widget.height,
      color: (_isJoined) ? Colors.white : Colors.white,//Color(COLOR_PRIMARY_VAL),
      bgColor: (_isJoined) ? Colors.blue : Colors.white.withOpacity(0.15),
      onPressed: toggleChannelJoinLeave,
      assetPath: 'images/drumm_logo.png',
    );
  }
}
