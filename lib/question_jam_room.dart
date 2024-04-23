import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';
import 'package:drumm_app/band_details_page.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/custom/listener/connection_listener.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/rounded_button.dart';
import 'model/Drummer.dart';
import 'model/article.dart';
import 'model/band.dart';
import 'model/drummer_join_card.dart';
import 'model/question.dart';

final StreamController<Map<int, bool>> _muteStreamController =
    StreamController<Map<int, bool>>.broadcast();
final StreamController<Map<int, bool>> _speechStreamController =
    StreamController<Map<int, bool>>.broadcast();

class QuestionJamRoomPage extends StatefulWidget {
  Jam jam;
  bool open;
  bool? ring;
  bool? micMute;
  Question? question;
  QuestionJamRoomPage(
      {Key? key,
      required this.jam,
      required this.open,
      this.ring,
        this.micMute,
      required this.question})
      : super(key: key);

  @override
  State<QuestionJamRoomPage> createState() => _JamRoomPageState();
}

class _JamRoomPageState extends State<QuestionJamRoomPage> {

  int mJoined = 1;
  List<dynamic> memberList = [];
  List<DrummerJoinCard> drummerCards = [];
  Drummer drummer = Drummer();

  Article? article;
  Band? band;

  bool userJoined = false;
  bool remoteUserJoined = false;

  bool shownWarning = false;
  double curve = 32;
  late BuildContext jamRoomContext;
  Drummer? localDrummer;
  Drummer? remoteDrummer;

  DrummerJoinCard? localJoinCard;
  DrummerJoinCard? remoteJoinCard;
  
  Drummer? loadingDrummer;
  bool micMute = true;

  @override
  Widget build(BuildContext context) {

    jamRoomContext = context;
    ConnectToChannel.jamRoomContext = context;
    ConnectToChannel.questionJamId = widget.jam.jamId ?? "";
    ConnectToChannel.jamQuestion = widget.question ?? Question();
    return Container(
      color: COLOR_PRIMARY_DARK, //Colors.black,
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: COLOR_PRIMARY_DARK.withOpacity(0.9),
          ),
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(false)ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: widget.jam.imageUrl ?? "",
                        height: 80,
                        fit: BoxFit.cover)),
                SizedBox(
                  height: 16,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "\"${widget.jam.question}\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: APP_FONT_MEDIUM,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (userJoined)
                      Expanded(
                        child: SizedBox(
                          width: (userJoined)?double.maxFinite:125,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            //color: Colors.grey.shade900,
                              height: 175, width: double.maxFinite,child: localJoinCard),
                        ),
                      ),
                    if(!userJoined)
                      Expanded(child: Container()),
                    if (remoteUserJoined)
                      Expanded(
                        child: SizedBox(
                          width: (userJoined)?double.maxFinite:125,
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              height: 175,width: double.maxFinite, child: remoteJoinCard),
                        ),
                      ),
                    if(!remoteUserJoined && loadingDrummer?.imageUrl!=null)
                      Expanded(child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          height: 175,width: double.maxFinite, 
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: loadingDrummer?.imageUrl??"", height: 175, color: Colors.grey.shade900.withOpacity(0.5),),
                          )),),
                    if(!remoteUserJoined && loadingDrummer?.imageUrl==null)
                      Expanded(child: Container()),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ),
              Text("Community Drumm",style: TextStyle(fontSize: 18,fontFamily: APP_FONT_MEDIUM),),
            ],
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!remoteUserJoined && remoteDrummer != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            "Wait for ${remoteDrummer?.username} to join the drumm",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator())
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TutorialBox(
                                  boxType: BOX_TYPE_CONFIRM,
                                  sharedPreferenceKey: CONFIRM_JOIN_SHARED_PREF,
                                  tutorialImageAsset: "images/audio-waves.png",
                                  tutorialMessage: LEAVE_DRUMM_CONFIRMATION,
                                  tutorialMessageTitle: LEAVE_DRUMM_TITLE,
                                  confirmColor: Colors.red.shade800,
                                  confirmMessage: "Confirm",
                                  onConfirm: () {
                                    ConnectToChannel.leaveChannel();
                                    FlutterCallkitIncoming.endAllCalls();

                                    if (drummerCards.length == 1) {
                                      FirebaseDBOperations.updateCount(
                                          widget.jam.jamId, 0);
                                    }

                                    Navigator.pop(jamRoomContext);
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: COLOR_PRIMARY_DARK,
                                border: Border.all(
                                    color: Colors.grey.shade900, width: 1),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "Leave Drumm",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_MEDIUM,
                              ),
                            ),
                          ),
                        ),
                      ),
                      RoundedButton(
                        height: 48,
                        padding: 12,
                        assetPath: micMute
                            ? "images/mic_off.png"
                            : "images/mic_on.png",
                        color: Colors.white,
                        bgColor: micMute ? Colors.grey.shade800 : Colors.blue,
                        onPressed: () {
                          setState(() {
                            Vibrate.feedback(FeedbackType.impact);
                            if (micMute) {
                              micMute = false;
                            } else {
                              micMute = true;
                            }

                            updateLocalUserMic(micMute);
                            ConnectToChannel.setMute(micMute);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    if (widget.jam.jamId != ConnectToChannel.jam?.jamId) {
      ConnectToChannel.jamRoomContext = context;
      ConnectToChannel.USERIDS_IN_DRUMM = [];
      ConnectToChannel.joinRoom(
          widget.jam,
          false,
          (joined, userID) {

          },
          widget.open,
          (val) {

          },
          (userJoined) {
            // int currUserRid = drummer.rid??0;
            // if(userJoined!=currUserRid){
            //   setState(() {
            //     remoteUserJoined = true;
            //   });
            // }
            // addUserToRoom(userJoined);
          },
          (userLeft) {
            // removeUserToRoom(userLeft);

            print("User has left the question Jam room");
          },
          (rid, mute) {
            // for(DrummerJoinCard dj in drummerCards){
            //   if(dj.drummerId == rid){
            //     setState(() {
            //       final updateMap = {rid: mute};
            //       _muteStreamController.sink.add(updateMap);
            //       if(mute)
            //         _speechStreamController.sink.add({rid: false});
            //     });
            //   }
            // }
          },
          (rid, talking) {
            //updateSpeech(rid,talking);
          },
          () {
            //connection Interrupted

            // setState(() {
            //   AnimatedSnackBar.material(
            //       "Trying to connect. Please check your internet connection.",
            //       type: AnimatedSnackBarType.error,
            //       mobileSnackBarPosition: MobileSnackBarPosition.top
            //   ).show(context);
            //   userJoined = false;
            // });
          },
          () {
            //rejoin success

            // setState(() {
            //   AnimatedSnackBar.material(
            //       "Rejoined",
            //       type: AnimatedSnackBarType.success,
            //       mobileSnackBarPosition: MobileSnackBarPosition.top
            //   ).show(context);
            //   userJoined = true;
            // });
          });
    } else {
      getLiveDetails();
    }

    String startedBy = widget.jam.startedBy ?? "";
    if (startedBy.isNotEmpty) getDrummer(startedBy);
    // if (widget.jam.bandId != null) getBand(widget.jam.bandId);
    setState(() {
      micMute = widget.micMute??ConnectToChannel.getMuteState();

      updateLocalUserMic(micMute);
      ConnectToChannel.setMute(micMute);
      print("Calling initState with micMute as ${micMute}");
    });

    // if (widget.jam.articleId != null) {
    //   getArticle(widget.jam.articleId);
    //   FirebaseDBOperations.updateJoined(widget.jam.articleId);
    // } else {
    //   print("Article ID is null ${widget.jam.articleId}");
    // }
    //getDrummers();

    getLoadingDrummer();
    listenToJamState();
  }

  void addUserToRoom(int rid) async {
    // List<DrummerJoinCard> dCards = drummerCards;
    // setState(() {
    //   drummerCards = [];
    //   drummerCards.clear();
    // });
    if (rid == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      rid = await FirebaseDBOperations.getDrummer(
              FirebaseAuth.instance.currentUser?.uid ??
                  prefs.getString('uid') ??
                  "")
          .then((value) => value.rid ?? rid);

      DrummerJoinCard drummerJoinCard = DrummerJoinCard(rid, true, false,
          _muteStreamController.stream, _speechStreamController.stream);

      setState(() {
        localJoinCard = drummerJoinCard;
        userJoined = true;
      });
      return;
    }

    DrummerJoinCard drummerJoinCard = DrummerJoinCard(rid, true, false,
        _muteStreamController.stream, _speechStreamController.stream);

    setState(() {
      remoteJoinCard = drummerJoinCard;
      remoteUserJoined = true;
    });
    return;
    // bool alreadyAdded = false;
    // for (DrummerJoinCard drummerCard in drummerCards) {
    //   if (drummerCard.drummerId == rid) alreadyAdded = true;
    // }

    // if (!alreadyAdded) {
    //   dCards.add(drummerJoinCard);
    // }

    setState(() {
      // drummerCards.clear();
      userJoined = true;
      // drummerCards = dCards;
      // drummerCards = [...state.drummerCards,drummerJoinCard];
      // if(!alreadyAdded) {
      //   drummerCards = List.from(drummerCards)
      //     ..add(drummerJoinCard);
      // }
      FirebaseDBOperations.updateCount(widget.jam.jamId, drummerCards.length);
    });
  }

  void removeUserToRoom(int rid) async {
    setState(() {
      // for (DrummerJoinCard dj in drummerCards) {
      //   if (dj.drummerId == rid) {
      //     //drummerCards.remove(dj);
      //     drummerCards = List.from(drummerCards)..remove(dj);
      //     break;
      //   }
      // }
      if(remoteJoinCard?.drummerId == rid)
        setState(() {
          remoteJoinCard = null;
          remoteUserJoined = false;
        });
      return;
    });
  }

  void getLiveDetails() {
    // FirebaseDBOperations.getJamData(widget.jam.jamId ?? "", widget.open)
    //     .then((jam) {
    //   setState(() {
    //     userJoined = true;
    //     memberList = jam.membersID ?? [];
    //     mJoined = jam.membersID?.length ?? 0;
    //     drummerCards = memberList
    //         .map((e) => DrummerJoinCard(e, true, false,
    //             _muteStreamController.stream, _speechStreamController.stream))
    //         .toList();
    //   });
    // });
    for (int userId in ConnectToChannel.USERIDS_IN_DRUMM) {
      int currUserRid = drummer.rid ?? 0;
      if (!remoteUserJoined) {
        if (userId != currUserRid) {
          setState(() {
            remoteUserJoined = true;
          });
        }
      }
      addUserToRoom(userId);
    }
  }

  void listenToJamState() {
    ConnectionListener.onConnectionChangedinRoom = (connected, jam, open) {
      // Handle the channelID change here
      // print("onConnectionChangedinRoom called in JamRoomPage");
      // getLiveDetails();
    };
    ConnectionListener.onRemoteUserJoinedCallback = (userId) {
      print("onRemoteUserJoinedCallback Remote user added : $userId");
      int currUserRid = drummer.rid ?? 0;
      if (userJoined != currUserRid) {
        setState(() {
          remoteUserJoined = true;
        });
      }
      addUserToRoom(userId);
    };
    ConnectionListener.onJoinCallback = (joined, userId) {
      print("$userId joinStatus $joined");
      // getLiveDetails();
      addUserToRoom(0);
    };
    ConnectionListener.onUserLeftCallback = (userLeft) {
      removeUserToRoom(userLeft);

      print("ConnectionListener.onUserLeftCallback called User has left the channel ");
    };
    ConnectionListener.onRejoinSuccessCallback = () {
      setState(() {
        AnimatedSnackBar.material("Rejoined",
                type: AnimatedSnackBarType.success,
                mobileSnackBarPosition: MobileSnackBarPosition.top)
            .show(context);
        userJoined = true;
      });
    };
    ConnectionListener.onConnectionInterruptedCallback = () {
      setState(() {
        AnimatedSnackBar.material(
                "Trying to connect. Please check your internet connection.",
                type: AnimatedSnackBarType.error,
                mobileSnackBarPosition: MobileSnackBarPosition.top)
            .show(context);
        userJoined = false;
      });
    };
    ConnectionListener.onUserTalkingCallback = (userId, talking) {
      updateSpeech(userId, talking);
    };
    ConnectionListener.onUserMutedCallback = (rid, mute) {
      //for (DrummerJoinCard dj in drummerCards) {
        //if (dj.drummerId == rid) {
      print("onUserMutedCallback rid: $rid");
          setState(() {
            final updateMap = {rid: mute};
            _muteStreamController.sink.add(updateMap);
            if (mute) _speechStreamController.sink.add({rid: false});
          });
        //}
      //}
    };
  }

  Future<Drummer> getDrummer(String? foundedBy) async {
    return FirebaseDBOperations.getDrummer(foundedBy!);
    //  .then((value) {
    //   setState(() {
    //     drummer = value;
    //   });
    // });
  }

  void getDrummers() async {
    Drummer fetchLocalDrummer =
        await getDrummer(FirebaseAuth.instance.currentUser?.uid);
    Drummer fetchRemoteDrummer = await getDrummer(widget.question?.uid);

    setState(() {
      localDrummer = fetchLocalDrummer;
      remoteDrummer = fetchRemoteDrummer;
    });
  }

  void getArticle(String? articleId) {
    FirebaseDBOperations.getArticle(articleId!).then((value) {
      setState(() {
        article = value;
      });
    });
  }

  void getBand(String? bandId) {
    FirebaseDBOperations.getBand(bandId!).then((value) {
      setState(() {
        band = value;
      });
    });
  }

  void updateSpeech(int rid, bool talking) async {
    print("UpdateSPeech $rid");
    if (rid == 0 && talking && micMute) {
      if (!shownWarning) {
        AnimatedSnackBar.material(
            'You are talking on mute',
            type: AnimatedSnackBarType.warning,
            mobileSnackBarPosition: MobileSnackBarPosition.bottom
        ).show(context);
        shownWarning = true;
        Vibrate.feedback(FeedbackType.heavy);
        Future.delayed(Duration(
          milliseconds: 10000
        ),() {
          shownWarning = false;
        },);
      }
    }

    bool showTalk = (rid == 0 && micMute) ? false : talking;

    if (rid == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      rid = await FirebaseDBOperations.getDrummer(
              FirebaseAuth.instance.currentUser?.uid ??
                  prefs.getString('uid') ??
                  "")
          .then((value) => value.rid ?? rid);
    }
    final updateMap = {rid: showTalk};

    // Add the update to the stream

    _speechStreamController.sink.add(updateMap);
  }

  void updateLocalUserMic(bool micMute) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int rid = await FirebaseDBOperations.getDrummer(
            FirebaseAuth.instance.currentUser?.uid ??
                prefs.getString('uid') ??
                "")
        .then((value) => value.rid ?? 0);
    final updateMap = {rid: micMute};
    _muteStreamController.sink.add(updateMap);
  }

  void getLoadingDrummer() async{
    String currentUserID = await FirebaseAuth.instance.currentUser?.uid??"";
    String remoteUserID = "";
    if(widget.question?.qid == currentUserID){
      remoteUserID = widget.jam.startedBy!;
    }else{
      remoteUserID = widget.question!.qid!;
    }
    Drummer fetchDrummer = await getDrummer(remoteUserID);
    setState(() {
      loadingDrummer = fetchDrummer;
    });
    
    
  }
}
