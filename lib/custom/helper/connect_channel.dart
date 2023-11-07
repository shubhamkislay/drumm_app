import 'dart:convert';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:algolia_insights/algolia_insights.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/listener/connection_listener.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef void JoinCallback(bool joined, int userID);
typedef void RemoteCallback(String message);
typedef void UserJoined(int remoteUid);
typedef void UserLeft(int remoteUid);
typedef void UserMute(int remoteUid, bool mute);
typedef void UserTalking(int remoteUid, bool talking);
typedef void ConnectionInterrupted();
typedef void RejoinSuccess();

class ConnectToChannel {
  static late RtcEngine _rtcEngine;
  static const String appId = "0608d9da67a9458db263b255c8f30778";

  static late Jam? jam = null;
  static bool micMute = true;
  static String serverUrl =
      "https://agora-token-service-production-d901.up.railway.app";
  static String token =
      "007eJxTYDi2XDj2UGSig8f0DawrP32q/z7PTbVP3LeBb22bvmmZ9n4FBgMzA4sUy5REM/NESxNTi5QkIzPjJCNT02SLNGMDc3OLZ+GLkxsCGRk2OLxjYIRCEJ+boSA/Pyc5IzEvLzWHgQEA8RwhmQ==";

  static bool engineInitialized = false; //
  static bool isTokenExpiring = false;

  static var insights = Insights( '6GGZ3SNOXT',  '490164dceb711d2a20364501566f7eb0');

  static String? channelID = "";
  static int tokenRole = 1;
  static int uid = 11;

  static bool _isJoined = false;
  static bool listenOnlyMode = false;
  static bool openJam = false;

  static late RtcEngineEventHandler rtcEngineEventHandler;

  static void setChannelID(String id) {
    channelID = id;
  }

  static void joinLiveDrumm(Article article, bool listenOnly) {
    openJam = true;
    Jam jam = Jam();
    jam.broadcast = false;
    jam.title = article.title;
    jam.bandId = article.category;
    jam.jamId = article.articleId;
    jam.articleId = article.articleId;
    jam.startedBy = article.source;
    jam.imageUrl = article.imageUrl;
    jam.count = 0;
    if (!listenOnly) {
      FirebaseDBOperations.createOpenDrumm(jam);
    }

    print("jamID created ${jam.jamId}");

    ConnectToChannel.joinRoom(jam, listenOnly, (joined, userID) {
      print("$userID joinStatus $joined");
    }, openJam, (val) {}, (rid) {},(leftUID){},(rid,mute){},(rid,talking){},(){},(){});
  }

  static void joinRoom(Jam _jam, bool listenOnly, JoinCallback joinCallback,
      bool open, RemoteCallback remoteCallback, UserJoined userJoined,
      UserLeft userLeft,UserMute userMute,UserTalking userTalking,
      ConnectionInterrupted connectionInterrupted,
      RejoinSuccess rejoinSuccess) async {
    await [Permission.microphone].request();
    // if(jam!=null)
    //   await leaveChannel();
    openJam = open;
    listenOnlyMode = listenOnly;

    if (!listenOnlyMode) await [Permission.microphone].request();

    try {
      int chanLen = channelID?.length ?? 0;
      if (chanLen > 0) {
        FirebaseDBOperations.removeMemberFromJam(channelID ?? "",
            FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
      }
    } catch (e) {
      print("You were connected to any drumms!");
    }

    try {
      _rtcEngine.unregisterEventHandler(rtcEngineEventHandler);
      _rtcEngine.release(sync: true);
    } catch (e) {
      print("Error unregisterEventHandler rtcEngineEventHandler");
    }
    jam = _jam;
    initializeEngine(_jam.jamId, (joined, id) {
      joinCallback(joined, id);
    }, (val) {
      remoteCallback(val);
    }, (rid) {
      userJoined(rid);
    },(leftUid){
      userLeft(leftUid);
    },(rid,mute){
      userMute(rid,mute);
    },(rid,talking){
      userTalking(rid,talking);
    },(){
      connectionInterrupted();
    },(){
      rejoinSuccess();
    }
    );
  }

  static Future<void> initializeEngine(
      String? _channelID,
      JoinCallback joinCallback,
      RemoteCallback remoteCallback,
      UserJoined userJoined, UserLeft userLeft,UserMute userMute,UserTalking userTalking,
      ConnectionInterrupted connectionInterrupted, RejoinSuccess rejoinSuccess) async {
    Random random = new Random();
    int randomNumber = random.nextInt(1000000001) + 1;
    print("User RANDOM ID GENERATED $randomNumber");

    //uid = randomNumber;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('isOnboarded');

    int rid = prefs.getInt('rid') ?? 0;
    String userid = prefs.getString('uid') ?? "";

    uid = await FirebaseDBOperations.getDrummer(
            FirebaseAuth.instance.currentUser?.uid ?? userid)
        .then((value) => value.rid ?? rid);
    remoteCallback("UserID for remote connected: $uid");
    channelID = _channelID;

    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine.initialize(const RtcEngineContext(appId: appId));
    engineInitialized = true;

    rtcEngineEventHandler = RtcEngineEventHandler(
      onConnectionLost: (RtcConnection connection) {
        // if (!listenOnlyMode)
        //   FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
        //       FirebaseAuth.instance.currentUser?.uid ?? "", openJam);

        remoteCallback("onConnectionLost");
      },

      onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
        //remote user mute status
        userMute(remoteUid,muted);
        print("Remote user muted: ${remoteUid}");
      },
      onConnectionInterrupted: (RtcConnection connection) {
        // if (!listenOnlyMode)
        //   FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
        //       FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
        connectionInterrupted();
        remoteCallback("onConnectionInterrupted");
      },
      onError: (ErrorCodeType err, String msg) {
        debugPrint("ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $msg");
        debugPrint("ERROR!!!!!!!!!!Reason!!!! $err");
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint("onTokenPrivilegeWillExpire called");
        print('Token expiring');
        isTokenExpiring = true;
        fetchToken(uid, channelID, tokenRole);
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (!listenOnlyMode) {
          debugPrint("onJoinChannelSuccess called channelID: $channelID");
          print(channelID);
          print("Local user uid:${connection.localUid} joined the channel");

          _isJoined = true;
          // FirebaseDBOperations.addMemberToJam(jam?.jamId ?? "",
          //     FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
          ConnectionListener.updateConnectionDetails(
              _isJoined, ConnectToChannel.jam, openJam);
          joinCallback(_isJoined, connection.localUid ?? uid);
        }
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        userJoined(remoteUid);
        if (!listenOnlyMode) {
          print("Remote user uid:$remoteUid joined the channel");
          joinCallback(_isJoined, remoteUid);
        }

        print("Remote user joined: ${remoteUid}");
       // remoteCallback("Remote user joined: ${remoteUid}");
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {

        userLeft(remoteUid);

        if (!listenOnlyMode) {
          print("Remote user uid:$remoteUid left the channel");
          joinCallback(false, remoteUid);
        }


        if(reason == UserOfflineReasonType.userOfflineDropped){
          remoteCallback("Remote user dropped: ${remoteUid}");
        }
        if(reason == UserOfflineReasonType.userOfflineQuit){
          remoteCallback("Remote user left: ${remoteUid}");
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats rtcStats) {
        if (!listenOnlyMode) {
          // FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
          //     FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
        }
        try {
          FirebaseDBOperations.stopListening();
        } catch (e) {
          print(e);
        }
      },
      onRejoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (!listenOnlyMode) {
          _isJoined = true;
          // FirebaseDBOperations.addMemberToJam(jam?.jamId ?? "",
          //     FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
          rejoinSuccess();
          ConnectionListener.updateConnectionDetails(
              _isJoined, ConnectToChannel.jam, openJam);
          joinCallback(_isJoined, connection.localUid ?? uid);
        }

        remoteCallback("onRejoinChannelSuccess");
      },
      onAudioVolumeIndication: (RtcConnection connection,
          List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
        if (speakers.length > 0 && speakers[0].uid == 0) {
          _rtcEngine.muteLocalAudioStream(micMute);
          if (!micMute) {
            // print(
            //     "onAudioVolumeIndication Volume changed speaker uid: ${speakers[0]
            //         .uid}"
            //         "\n speaker volume${speakers[0].volume}");
            bool speaking = false;
            if (speakers[0].volume! > 50) {
              speaking = true;
            }
            FirebaseDBOperations.updateDrummerSpeaking(speaking);
          } else {
            FirebaseDBOperations.updateDrummerSpeaking(false);
          }
        }
        ConnectionListener.updateConnectionDetails(
            _isJoined, ConnectToChannel.jam, openJam);

        for (AudioVolumeInfo audioVolumeInfo in speakers) {
        //  print("Speaker info: ${audioVolumeInfo.uid}");
          if (audioVolumeInfo.volume! > 50) {
           // remoteCallback("Speaker ${audioVolumeInfo.uid} is talking");
            userTalking(audioVolumeInfo.uid??0,true);
          }
          else
            {
              userTalking(audioVolumeInfo.uid??0,false);
            }
        }
      },
    );

    micMute = true;
    _rtcEngine.muteLocalAudioStream(micMute);
    _rtcEngine.enableAudioVolumeIndication(
        interval: 300, smooth: 6, reportVad: true);
    _rtcEngine.registerEventHandler(rtcEngineEventHandler);

    // await _rtcEngine.enableAudio();
    await _rtcEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard);
    join();
  }

  static void join() async {
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

    await fetchToken(uid, channelID, tokenRole);
  }

  static Future<void> leaveChannel() async {
    micMute = true;
    FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
        FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
    await _rtcEngine.leaveChannel();
    FlutterCallkitIncoming.endAllCalls();
    disposeEngine();
  }

  static void setMute(bool mute) {
    try {
      _rtcEngine.muteLocalAudioStream(mute);
      micMute = mute;
    } catch (e) {
      print("Error while muting because $e");
    }
  }

  static bool getMuteState() {
    return micMute;
  }

  static Future<void> fetchToken(
      int uid, String? channelName, int tokenRole) async {
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

  static void setToken(String newToken) async {
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
      ChannelMediaOptions listenOnly = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      );

      ChannelMediaOptions? mode;
      if (listenOnlyMode)
        mode = listenOnly;
      else
        mode = options;

      await _rtcEngine.joinChannel(
        token: token,
        channelId: channelID ?? "",
        options: mode ?? options,
        uid: uid,
      );
    }
  }

  static void disposeEngine() {
    print("Disposing Article Channel");
    _rtcEngine.unregisterEventHandler(rtcEngineEventHandler);
    if (engineInitialized) {
      _rtcEngine.release(sync: true);
      channelID = "";
      engineInitialized = false;
    }
    channelID = "";

    //dispose();
    _isJoined = false;
    ConnectionListener.updateConnectionDetails(
        _isJoined, ConnectToChannel.jam, openJam);
    jam = null;
  }
}
