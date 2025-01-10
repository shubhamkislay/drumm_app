import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:algolia_insights/algolia_insights.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/model/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/listener/connection_listener.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drumm_app/proto/proto/agora_transcription.pb.dart';


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
  static String questionJamId = "";
  static Question jamQuestion = Question();

  static late Jam? jam = null;
  static bool micMute = true;
  static String serverUrl =
      "https://agora-token-service-production-d901.up.railway.app";
  static String token =
      "007eJxTYDi2XDj2UGSig8f0DawrP32q/z7PTbVP3LeBb22bvmmZ9n4FBgMzA4sUy5REM/NESxNTi5QkIzPjJCNT02SLNGMDc3OLZ+GLkxsCGRk2OLxjYIRCEJ+boSA/Pyc5IzEvLzWHgQEA8RwhmQ==";

  static String customerKey = "42cc54f232f64ed0beb67911d7bcb863";
  static String customerSecret = "2fd744848afa4adebd6c64ac56c8cce9";

  static bool engineInitialized = false; //
  static bool isTokenExpiring = false;

  static var insights = Insights(
      applicationID: '6GGZ3SNOXT', apiKey: '490164dceb711d2a20364501566f7eb0');

  static String? channelID = "";
  static late BuildContext jamRoomContext;
  static int tokenRole = 1;
  static int uid = 11;

  static bool _isJoined = false;
  static bool listenOnlyMode = false;
  static bool openJam = false;
  static List<int> USERIDS_IN_DRUMM = [];

  static late RtcEngineEventHandler rtcEngineEventHandler;
  static Timer? _updateLastActiveTimer;

  static String channelName = "YOUR_CHANNEL_NAME";
  final String subBotUid = "12345"; // Replace with unique UID
  final String pubBotUid = "54321"; // Replace with unique UID
  static String builderToken = "";
  String resourceId = "";
  static String taskId = "";
  String transcriptionStatus = "Idle";
  static String authorizationField = "";

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
    jam.lastActive = Timestamp.now();
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
    }, openJam, (val) {}, (rid) {}, (leftUID) {}, (rid, mute) {},
        (rid, talking) {}, () {}, () {});
  }

  static void joinRoom(
      Jam _jam,
      bool listenOnly,
      JoinCallback joinCallback,
      bool open,
      RemoteCallback remoteCallback,
      UserJoined userJoined,
      UserLeft userLeft,
      UserMute userMute,
      UserTalking userTalking,
      ConnectionInterrupted connectionInterrupted,
      RejoinSuccess rejoinSuccess) async {
    await [Permission.microphone].request();
    // if(jam!=null)
    //   await leaveChannel();
    openJam = open;
    listenOnlyMode = listenOnly;

    if (!listenOnlyMode) await [Permission.microphone].request();

    try {
      //if (_updateLastActiveTimer!.isActive) {
      _updateLastActiveTimer!.cancel();
      // }
    } catch (e) {}

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
    }, (leftUid) {
      userLeft(leftUid);
    }, (rid, mute) {
      userMute(rid, mute);
    }, (rid, talking) {
      userTalking(rid, talking);
    }, () {
      connectionInterrupted();
    }, () {
      rejoinSuccess();
    });
  }

  static Future<void> initializeEngine(
      String? _channelID,
      JoinCallback joinCallback,
      RemoteCallback remoteCallback,
      UserJoined userJoined,
      UserLeft userLeft,
      UserMute userMute,
      UserTalking userTalking,
      ConnectionInterrupted connectionInterrupted,
      RejoinSuccess rejoinSuccess) async {
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
    await _rtcEngine.initialize(const RtcEngineContext(appId: appId,));
    engineInitialized = true;

    rtcEngineEventHandler = RtcEngineEventHandler(
      onConnectionLost: (RtcConnection connection) {
        // if (!listenOnlyMode)
        //   FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
        //       FirebaseAuth.instance.currentUser?.uid ?? "", openJam);

        remoteCallback("onConnectionLost");
        stopTranscriptionService();
      },
      onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
        //remote user mute status
        //userMute(remoteUid,muted);
        ConnectionListener.updateUserMuted(remoteUid, muted);
        print("Remote user muted: ${remoteUid}");
      },
      onConnectionInterrupted: (RtcConnection connection) {
        // if (!listenOnlyMode)
        //   FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
        //       FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
        //connectionInterrupted();
        ConnectionListener.connectionInterruptedCallback();
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
        setToken(generateAgoraToken(uid.toString(), RtcRole.publisher));
        //fetchToken(uid, channelID, tokenRole);
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (!listenOnlyMode) {
          debugPrint("onJoinChannelSuccess called channelID: $channelID");
          print(channelID);
          print("Local user uid:${connection.localUid} joined the channel");
          //onPlayMusicPressed();
          acquireResource(channelID??"");

          _isJoined = true;
          // Start the timer to call updateLastActive every 10 seconds

          // FirebaseDBOperations.addMemberToJam(jam?.jamId ?? "",
          //     FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
          if (!USERIDS_IN_DRUMM.contains(0)) {
            USERIDS_IN_DRUMM.add(0);
          }

          ConnectionListener.updateConnectionDetails(
              _isJoined, ConnectToChannel.jam, openJam, micMute);
          //joinCallback(_isJoined, connection.localUid ?? uid);
          ConnectionListener.updateJoinCallback(
              _isJoined, connection.localUid ?? uid);
        }
        _updateLastActiveTimer = Timer.periodic(Duration(seconds: 10), (timer) {
          if (_isJoined) {
            FirebaseDBOperations.updateLastActive(
                channelID!); // Call the updateLastActive function
          }
        });

        // Call the updateLastActive function immediately after joining
        if (_isJoined) {
          FirebaseDBOperations.updateLastActive(channelID!);
        }
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        // userJoined(remoteUid);
        if (!USERIDS_IN_DRUMM.contains(remoteUid)) {
          USERIDS_IN_DRUMM.add(remoteUid);
        }
        ConnectionListener.updateRemoteUserJoined(remoteUid);
        //ConnectionListener.updateJoinCallback(_isJoined, remoteUid);
        if (!listenOnlyMode) {
          print("Remote user uid:$remoteUid joined the channel");
          //joinCallback(_isJoined, remoteUid);
        }

        //ConnectionListener.updateRemoteUserJoined(remoteUid);
        //ConnectionListener.updateJoinCallback(_isJoined, remoteUid);
        print("Remote user joined: ${remoteUid}");
        // remoteCallback("Remote user joined: ${remoteUid}");
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        //userLeft(remoteUid);
        ConnectionListener.updateUserLeft(remoteUid);
        USERIDS_IN_DRUMM.remove(remoteUid);

        if (!listenOnlyMode) {
          print("Remote user uid:$remoteUid left the channel");
          //joinCallback(false, remoteUid);
          //ConnectionListener.updateJoinCallback(false, remoteUid);
        }

        if (reason == UserOfflineReasonType.userOfflineDropped) {
          remoteCallback("Remote user dropped: ${remoteUid}");
        }
        if (reason == UserOfflineReasonType.userOfflineQuit) {
          remoteCallback("Remote user left: ${remoteUid}");
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats rtcStats) {
        stopTranscriptionService();

        if (!listenOnlyMode) {
          // FirebaseDBOperations.removeMemberFromJam(jam?.jamId ?? "",
          //     FirebaseAuth.instance.currentUser?.uid ?? "", openJam);
        }
        _updateLastActiveTimer?.cancel();

        print("User has left the channel ${_channelID}");

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
          //rejoinSuccess();
          ConnectionListener.rejoinSuccessCallback();
          ConnectionListener.updateConnectionDetails(
              _isJoined, ConnectToChannel.jam, openJam, micMute);
          //joinCallback(_isJoined, connection.localUid ?? uid);
          ConnectionListener.updateJoinCallback(
              _isJoined, connection.localUid ?? uid);
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
            //FirebaseDBOperations.updateLastActive(channelID!);
          } else {
            FirebaseDBOperations.updateDrummerSpeaking(false);
          }
        }
        ConnectionListener.updateConnectionDetails(
            _isJoined, ConnectToChannel.jam, openJam, micMute);

        for (AudioVolumeInfo audioVolumeInfo in speakers) {
          //  print("Speaker info: ${audioVolumeInfo.uid}");
          if (audioVolumeInfo.volume! > 50) {
            // remoteCallback("Speaker ${audioVolumeInfo.uid} is talking");
            userTalking(audioVolumeInfo.uid ?? 0, true);
            ConnectionListener.updateUserTalking(
                audioVolumeInfo.uid ?? 0, true);
          } else {
            userTalking(audioVolumeInfo.uid ?? 0, false);
            ConnectionListener.updateUserTalking(
                audioVolumeInfo.uid ?? 0, false);
          }
        }
      },
      onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
        print("Transcribing!!!!!!!!");
        parseTranscriptionData(data);
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

  static void parseTranscriptionData(Uint8List data) {
    try {
      // Decode binary data into a `Text` object
      ProtoText transcription = ProtoText.fromBuffer(data);

      // Access the parsed fields
      print("Vendor: ${transcription.vendor}");
      print("Version: ${transcription.version}");
      print("Sequence Number: ${transcription.seqnum}");
      print("User ID: ${transcription.uid}");
      print("Flag: ${transcription.flag}");
      print("Time: ${transcription.time}");
      print("Language: ${transcription.lang}");
      print("Start Time: ${transcription.starttime}");
      print("Off Time: ${transcription.offtime}");
      print("End of Segment: ${transcription.endOfSegment}");
      print("Duration: ${transcription.durationMs}");
      print("Data Type: ${transcription.dataType}");
      print("Culture: ${transcription.culture}");
      print("Text Timestamp: ${transcription.textTs}");

      // Print words
      for (var word in transcription.words) {
        print("Word: ${word.text}, Start MS: ${word.startMs}, Duration: ${word.durationMs}");
      }

      // Print translations
      for (var translation in transcription.trans) {
        print("Translation Language: ${translation.lang}, Texts: ${translation.texts}");
      }
    } catch (e) {
      print("Error parsing transcription data: $e");
    }
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
    setToken(generateAgoraToken(uid.toString(), RtcRole.publisher));
    //await fetchToken(uid, channelID, tokenRole);
  }

  static Future<void> onPlayMusicPressed() async {
    const firebasePath = "aivoice/introduction.mp3";

    await FirebaseDBOperations.convertTextToSpeech(
        "Welcome to your first Drumm. Here you can talk to me your Drumm AI, and other people as well on the latest pressing issues around the world. Like for this example. ${jam?.question}. Wait for others to join." ??
            "This is a test question",
        jam?.jamId ?? "id1234",
        _rtcEngine);

    // await FirebaseDBOperations.playMusicFromFirebase(
    //   firebaseStorageFilePath: firebasePath,
    //   engine: _rtcEngine,
    //   loopback: false,  // publish to remote participants only
    //   replace: false,   // mix mic + music
    //   cycle: 1,         // play once
    // );
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
      queryTranscriptionService();
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

      await _rtcEngine
          .joinChannel(
        token: token,
        channelId: channelID ?? "",
        options: mode ?? options,
        uid: uid,
      )
          .onError((error, stackTrace) {
        print("${error}");
      });
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
        _isJoined, ConnectToChannel.jam, openJam, micMute);
    jam = null;
  }

  static void setupAuthorizationField(String customerKey, String customerSecret) {
    // Concatenate customerKey and customerSecret with a colon
    final String plainCredential = "$customerKey:$customerSecret";

    // Encode the concatenated string with Base64
    final String encodedCredential = base64Encode(utf8.encode(plainCredential));

    // Create the Authorization field
    authorizationField = "Basic $encodedCredential";

    // Print or use the authorizationField as needed
    print("Authorization Field: $authorizationField");
  }

  static Future<String> acquireResource(String channelId) async {

    setupAuthorizationField(customerKey, customerSecret);

    final String url = "https://api.agora.io/v1/projects/$appId/rtsc/speech-to-text/builderTokens";

    channelName = channelId;

    final headers = {
      "Authorization":authorizationField,
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "instanceId": channelID, // Channel name or unique identifier
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      builderToken = data["tokenName"];
      print("Resource acquired: $builderToken");
      startTranscription();
      return builderToken;
    } else {
      throw Exception("Failed to acquire resource: ${response.body}");
    }
  }


  static Future<String> startTranscription() async {
    final String url = "https://api.agora.io/v1/projects/$appId/rtsc/speech-to-text/tasks?builderToken=$builderToken";

    final headers = {
      "Authorization":authorizationField,
      "Content-Type": "application/json",
    };
    Random random = new Random();
    String subBotUid = random.nextInt(1000000001).toString();
    String pubBotUid = random.nextInt(1000000001).toString();

    final body = jsonEncode({
      "languages": ["en-US"], // Specify transcription language
      "maxIdleTime": 300, // Stop service if no activity for 60 seconds
      "rtcConfig": {
        "channelName": channelID, // Channel name
        "subBotUid": subBotUid,
        "subBotToken":generateAgoraToken(subBotUid, RtcRole.subscriber),// Unique UID for subscribing bot
        "pubBotUid": pubBotUid,
        "pubBotToken":generateAgoraToken(pubBotUid,RtcRole.subscriber),// Unique UID for publishing bot
      },
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      taskId = data["taskId"];
      print("Service started: $taskId");
      print("Status : ${data["status"]}");
      queryTranscriptionService();
      queryTranscriptionWithRetry(3,2000);
      return taskId;
    } else {
      throw Exception("Failed to start transcription: ${response.body}");
    }
  }


  static Future<void> queryTranscriptionService() async {
    // Agora RESTful API URL for querying the transcription task
    print("Task id is ${taskId}");
    print("Builder Token is ${builderToken}");
    print("Channel ID ${channelID}");
    final String url =
        "https://api.agora.io/v1/projects/$appId/rtsc/speech-to-text/tasks/$taskId?builderToken=$builderToken";

    final headers = {
      "Authorization":authorizationField,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Transcription Task Status:");
        print("Task ID: ${data['taskId']}");
        print("Status: ${data['status']}");
      } else {
        print("Failed to query transcription: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }


  static Future<void> stopTranscriptionService() async {
    // Agora RESTful API URL for stopping the transcription task
    print("Task ID: ${taskId}");
    final String url =
        "https://api.agora.io/v1/projects/$appId/rtsc/speech-to-text/tasks/$taskId?builderToken=$builderToken";

    final headers = {
      "Authorization":authorizationField,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print("Transcription task stopped successfully.");
      } else {
        print("Failed to stop transcription: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  static Future<void> queryTranscriptionWithRetry(int retries, int delayMs) async {
    for (int i = 0; i < retries; i++) {
      try {
        await queryTranscriptionService();
        return; // Exit if query succeeds
      } catch (e) {
        print("Retrying query... Attempt ${i + 1}");
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    print("Failed to query transcription after $retries attempts.");
  }

  static String generateAgoraToken(String uid, RtcRole role){

    Random random = new Random();
    int randomNumber = random.nextInt(1000000001) + 1;
    // Current timestamp
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Expiry timestamp
    final int privilegeExpiredTs = currentTimestamp + 3600;
    return token = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: "d0a390bebb284783833a0f4f46203a4b",
      channelName: channelID??jam?.jamId??channelName,
      uid: uid,
      role: role,
      expireTimestamp: privilegeExpiredTs,
    );
  }
}
