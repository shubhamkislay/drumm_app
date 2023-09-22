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

import 'custom/rounded_button.dart';
import 'model/Drummer.dart';
import 'model/article.dart';
import 'model/band.dart';
import 'model/drummer_join_card.dart';

class JamRoomPage extends StatefulWidget {
  Jam jam;
  bool open;
  bool? ring;
  JamRoomPage({Key? key, required this.jam, required this.open, this.ring})
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: COLOR_PRIMARY_DARK, //Colors.black,
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
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
                          MaterialPageRoute(
                              builder: (context) => OpenArticlePage(
                                    article: article ?? Article(),
                                  )));
                    },
                    child: Container(
                      height: 120,
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade900,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              height: 100,
                              width: 100,
                              imageUrl: article?.imageUrl ??
                                  "", //widget.article?.imageUrl ?? "",
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorWidget: (context, url, error) {
                                return Container(color: COLOR_PRIMARY_DARK);
                              },
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
                const SizedBox(
                  height: 4,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 16.0, left: 16),
                  child: Text(
                    widget.jam.title ?? "",
                    style: TextStyle(fontSize: 22),
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
                      color: COLOR_PRIMARY_DARK,
                      border: const Border(
                        top: BorderSide(
                          color: Colors.white12,
                          width: 1.0,
                        ),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (jamImageCards.isNotEmpty)
                      //   Container(
                      //     alignment: Alignment.topCenter,
                      //     child: GridView.custom(
                      //       shrinkWrap: true,
                      //       physics: const NeverScrollableScrollPhysics(),
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 2, vertical: 2),
                      //       gridDelegate: SliverQuiltedGridDelegate(
                      //         crossAxisCount: 3,
                      //         mainAxisSpacing: 3,
                      //         crossAxisSpacing: 3,
                      //         repeatPattern: QuiltedGridRepeatPattern.inverted,
                      //         pattern: [
                      //           const QuiltedGridTile(2, 1),
                      //           const QuiltedGridTile(2, 1),
                      //           const QuiltedGridTile(2, 1),
                      //         ],
                      //       ),
                      //       childrenDelegate: SliverChildBuilderDelegate(
                      //         childCount: jamImageCards.length,
                      //             (context, index) => jamImageCards.elementAt(index),
                      //       ),
                      //     ),
                      //   ),
                      if (false)
                        Text(
                          "Joining Drumm...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (!userJoined)
                        Lottie.asset('images/animation_loading.json',
                            height: 400,
                            fit: BoxFit.contain,
                            width: double.maxFinite),
                      if (drummerCards.length > 0)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GridView.count(
                            childAspectRatio: 0.85,
                            crossAxisCount:
                                3, //(drummerCards.length > 4) ? 3 : 2, // Number of columns
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
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
                            fontWeight: FontWeight.bold, fontSize: 16),
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ConnectToChannel.leaveChannel();
                        FlutterCallkitIncoming.endAllCalls();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(14)),
                        child: Text(
                          "Leave Drumm",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  RoundedButton(
                    height: 48,
                    padding: 12,
                    assetPath:
                        micMute ? "images/mic_off.png" : "images/mic_on.png",
                    color: Colors.white,
                    bgColor: micMute ? Colors.red : Colors.green,
                    onPressed: () {
                      setState(() {
                        Vibrate.feedback(FeedbackType.impact);
                        if (micMute)
                          micMute = false;
                        else
                          micMute = true;

                        ConnectToChannel.setMute(micMute);
                      });
                    },
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

  //  if (widget.jam.jamId != ConnectToChannel.jam?.jamId) {
      ConnectToChannel.joinRoom(
          widget.jam,
          false,
          (joined, userID) {
            print("$userID joinStatus $joined");
            // getLiveDetails();
            addUserToRoom(0);
          },
          widget.open,
          (val) {
            print("Calling log from jam_room!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            setState(() {
              AnimatedSnackBar.material(val,
                      type: AnimatedSnackBarType.success,
                      mobileSnackBarPosition: MobileSnackBarPosition.top)
                  .show(context);
            });
          },
          (userJoined) {
            addUserToRoom(userJoined);
          },
          (userLeft) {
            removeUserToRoom(userLeft);
          });
   // } //else
    // getLiveDetails();

    String startedBy = widget.jam.startedBy ?? "";
    if (startedBy.length > 0) getDrummer(startedBy);
    if (widget.jam.bandId != null) getBand(widget.jam.bandId);
    setState(() {
      micMute = ConnectToChannel.getMuteState();
    });

    if (widget.jam.articleId != null)
      getArticle(widget.jam.articleId);
    else
      print("Article ID is null ${widget.jam.articleId}");

    listenToJamState();
  }

  void addUserToRoom(int rid) async{
    List<DrummerJoinCard> dCards = drummerCards;
    setState(() {
      drummerCards = [];
      drummerCards.clear();
    });
    if(rid==0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      rid = await FirebaseDBOperations.getDrummer(
          FirebaseAuth.instance.currentUser?.uid ?? prefs.getString('uid') ?? "")
          .then((value) => value.rid ?? rid);
    }

    bool alreadyAdded = false;
    for(DrummerJoinCard drummerCard in dCards){
      if(drummerCard.drummerId == rid)
        alreadyAdded = true;
    }
    if(!alreadyAdded) {
      dCards.add(DrummerJoinCard(rid));
      // AnimatedSnackBar.material("$rid Added to room",
      //     type: AnimatedSnackBarType.success,
      //     mobileSnackBarPosition: MobileSnackBarPosition.top)
      //     .show(context);
    }

    setState(() {
     // drummerCards.clear();
      userJoined = true;
      drummerCards = dCards;
    });

  }
  void removeUserToRoom(int rid) async{
    setState(() {
      for(DrummerJoinCard dj in drummerCards)
      {
        if(dj.drummerId == rid)
          drummerCards.remove(dj);
      }
    });

    // setState(() {
    //   drummerCards = [];
    //   drummerCards.clear();
    // });

    // List<DrummerJoinCard> dCards = drummerCards;
    // dCards.where((element) {
    //   if (element.drummerId == rid) {
    //
    //     AnimatedSnackBar.material("$rid Removed from room",
    //         type: AnimatedSnackBarType.success,
    //         mobileSnackBarPosition: MobileSnackBarPosition.top)
    //         .show(context);
    //
    //    // List<DrummerJoinCard> dCards = drummerCards;
    //     dCards.remove(element);
    //     return true;
    //   } else
    //     return false;
    // });
    //
    // setState(() {
    //   // drummerCards.clear();
    //   drummerCards = dCards;
    // });
  }

  void getLiveDetails() {
    FirebaseDBOperations.getJamData(widget.jam.jamId ?? "", widget.open)
        .then((jam) {
      setState(() {
        userJoined = true;
        memberList = jam.membersID ?? [];
        mJoined = jam.membersID?.length ?? 0;
        drummerCards = memberList.map((e) => DrummerJoinCard(e)).toList();
      });
    });
  }

  void listenToJamState() {
    ConnectionListener.onConnectionChangedinRoom = (connected, jam, open) {
      // Handle the channelID change here
     // print("onConnectionChangedinRoom called in JamRoomPage");
     // getLiveDetails();
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
}
