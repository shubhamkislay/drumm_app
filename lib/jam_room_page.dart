import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

final StreamController<Map<int, bool>> _muteStreamController =
    StreamController<Map<int, bool>>.broadcast();
final StreamController<Map<int, bool>> _speechStreamController =
    StreamController<Map<int, bool>>.broadcast();

class JamRoomPage extends StatefulWidget {
  Jam jam;
  bool open;
  bool? ring;
  bool? micMute;
  JamRoomPage({Key? key, required this.jam, required this.open, this.ring, this.micMute})
      : super(key: key);

  @override
  State<JamRoomPage> createState() => _JamRoomPageState();
}

class _JamRoomPageState extends State<JamRoomPage> {
  bool micMute = true;
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

  @override
  Widget build(BuildContext context) {
    jamRoomContext = context;
    ConnectToChannel.jamRoomContext = context;
    return Container(
      color: COLOR_PRIMARY_DARK, //Colors.black,
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
          // if (userJoined)
          // Container(
          //   alignment: Alignment.center,
          //   padding: EdgeInsets.all(8),
          //   child: Lottie.asset('images/wave_drumm.json',height: MediaQuery.of(context).size.height/2,fit:BoxFit.contain),
          // ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: COLOR_PRIMARY_DARK.withOpacity(0.9),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                if (article?.articleId != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          SwipeablePageRoute(
                              builder: (context) => OpenArticlePage(
                                    article: article ?? Article(),
                                  )));
                    },
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(curve),
                        color: COLOR_PRIMARY_DARK,
                        border:
                            Border.all(color: Colors.grey.shade900, width: 1),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(curve - 4),
                              child: CachedNetworkImage(
                                width: 100,
                                height: double.infinity,
                                imageUrl: article?.imageUrl ??
                                    "", //widget.article?.imageUrl ?? "",
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorWidget: (context, url, error) {
                                  return Container(color: COLOR_PRIMARY_DARK);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: ExpandableText(
                                article?.title ?? "",
                                expandText: 'show more',
                                collapseText: 'show less',
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: APP_FONT_MEDIUM,
                                ),
                                linkColor: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.jam?.question != null)
                  const SizedBox(
                    height: 4,
                  ),
                if (widget.jam?.question != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 16.0, left: 16),
                    child: Text(
                      "\"${widget.jam.question}\"",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: APP_FONT_BOLD,
                      ),
                    ),
                  ),
                if (false)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 4.0, left: 16),
                    child: Text(
                      "Generated by Drumm AI",
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                  ),
                const SizedBox(
                  height: 4,
                ),
                if (drummer?.username != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 16.0, left: 16),
                    child: Text(
                      widget.jam.title ?? "",
                      style:
                          TextStyle(fontSize: 22, fontFamily: APP_FONT_MEDIUM),
                    ),
                  ),
                if (drummer?.username != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 12, top: 8, bottom: 12),
                    child: Row(
                      children: [
                        Text(
                          "Started by",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: APP_FONT_MEDIUM,
                              color: Colors.white54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfilePage(
                                    drummer: drummer,
                                    fromSearch: true,
                                  ),
                                ));
                          },
                          child: Text(
                            " @${drummer?.username}",
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: APP_FONT_MEDIUM,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(1),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      // color: (jamImageCards.isNotEmpty)
                      //     ? COLOR_PRIMARY_DARK
                      //     : Colors.black,
                      color: Colors.transparent, //COLOR_PRIMARY_DARK,
                      border: Border(
                        top: BorderSide(
                          color: (drummer?.username != null)
                              ? Colors.white12
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!userJoined)
                        Container(
                          height: 400,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Lottie.asset('images/join_room.json',
                                  fit: BoxFit.contain,
                                  height: double.maxFinite,
                                  width: double.maxFinite),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.grey.shade900.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Connecting...",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: APP_FONT_MEDIUM,
                                        fontSize: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (drummerCards.isNotEmpty && userJoined)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: GridView.count(
                            childAspectRatio: 0.825,
                            crossAxisCount:
                                (drummerCards.length >= 6) ? 4 : 3, // Number of columns
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            crossAxisSpacing: (drummerCards.length >= 6) ? 8:12,
                            mainAxisSpacing: (drummerCards.length >= 6) ?6:12,
                            children: drummerCards,
                          ),
                        ),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                )
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
              if (band?.url != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BandDetailsPage(
                                    band: band ?? Band(),
                                  )));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ExpandableText(
                        band?.name ?? "",
                        expandText: 'show more',
                        collapseText: 'show less',
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        maxLines: 3,
                        linkColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
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
                  if (!remoteUserJoined)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            "Wait for others to join the drumm",
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
            // print("$userID joinStatus $joined");
            // // getLiveDetails();
            // addUserToRoom(0);
          },
          widget.open,
          (val) {
            // AnimatedSnackBar.material(
            //     val,
            //     type: AnimatedSnackBarType.success,
            //     mobileSnackBarPosition: MobileSnackBarPosition.top
            // ).show(context);
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
    if (widget.jam.bandId != null) getBand(widget.jam.bandId);
    setState(() {
      micMute = widget.micMute??ConnectToChannel.getMuteState();

      updateLocalUserMic(micMute);
      ConnectToChannel.setMute(micMute);
      print("Calling initState with micMute as ${micMute}");
    });

    if (widget.jam.articleId != null) {
      getArticle(widget.jam.articleId);
      FirebaseDBOperations.updateJoined(widget.jam.articleId);
    } else {
      print("Article ID is null ${widget.jam.articleId}");
    }

    listenToJamState();
  }

  void addUserToRoom(int rid) async {
    // List<DrummerJoinCard> dCards = drummerCards;
    // setState(() {
    //   drummerCards = [];
    //   drummerCards.clear();
    // });
    bool muted = rid == 0?widget.micMute??true:true;
    if (rid == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      rid = await FirebaseDBOperations.getDrummer(
              FirebaseAuth.instance.currentUser?.uid ??
                  prefs.getString('uid') ??
                  "")
          .then((value) => value.rid ?? rid);
    }



    DrummerJoinCard drummerJoinCard = DrummerJoinCard(rid, muted, false, _muteStreamController.stream,
        _speechStreamController.stream);
    bool alreadyAdded = false;
    for (DrummerJoinCard drummerCard in drummerCards) {
      if (drummerCard.drummerId == rid) alreadyAdded = true;
    }

    // if (!alreadyAdded) {
    //   dCards.add(drummerJoinCard);
    // }

    setState(() {
      // drummerCards.clear();
      userJoined = true;
      // drummerCards = dCards;
      // drummerCards = [...state.drummerCards,drummerJoinCard];
      if(!alreadyAdded) {
        drummerCards = List.from(drummerCards)
          ..add(drummerJoinCard);
      }
      FirebaseDBOperations.updateCount(widget.jam.jamId, drummerCards.length);
    });
  }

  void removeUserToRoom(int rid) async {
    setState(() {
      for (DrummerJoinCard dj in drummerCards) {
        if (dj.drummerId == rid) {
          //drummerCards.remove(dj);
          drummerCards = List.from(drummerCards)
            ..remove(dj);
          break;
        }
      }
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
    for(int userId in ConnectToChannel.USERIDS_IN_DRUMM){
      int currUserRid = drummer.rid ?? 0;
      if(!remoteUserJoined) {
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
      for (DrummerJoinCard dj in drummerCards) {
        if (dj.drummerId == rid) {
          setState(() {
            final updateMap = {rid: mute};
            _muteStreamController.sink.add(updateMap);
            if (mute) _speechStreamController.sink.add({rid: false});
          });
        }
      }
    };
  }

  void getDrummer(String? foundedBy) {
    FirebaseDBOperations.getDrummer(foundedBy!).then((value) {
      setState(() {
        drummer = value;
      });
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
    if (rid == 0 && talking && micMute) {
      if (!shownWarning) {
        // AnimatedSnackBar.material(
        //     'You are talking on mute',
        //     type: AnimatedSnackBarType.warning,
        //     mobileSnackBarPosition: MobileSnackBarPosition.bottom
        // ).show(context);
        // shownWarning = true;
        // Vibrate.feedback(FeedbackType.heavy);
        // Future.delayed(Duration(
        //   milliseconds: 10000
        // ),() {
        //   shownWarning = false;
        // },);
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
}
