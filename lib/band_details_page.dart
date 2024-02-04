import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/jam_image_card.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/user_profile_page.dart';
import 'package:flutter_chip_tags/flutter_chip_tags.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EditBand.dart';
import 'ShareWidget.dart';
import 'custom/TutorialBox.dart';
import 'custom/constants/Constants.dart';
import 'custom/helper/connect_channel.dart';
import 'model/Drummer.dart';
import 'model/band.dart';
import 'profile_page.dart';

class BandDetailsPage extends StatefulWidget {
  Band? band;
  BandDetailsPage({Key? key, this.band}) : super(key: key);

  @override
  State<BandDetailsPage> createState() => BandDetailsPageState();
}

class BandDetailsPageState extends State<BandDetailsPage> {
  String profileImageUrl = "";
  List<Container> memberCards = [];
  List<String> categoryList = [];
  Band? band = Band();
  Drummer drummer = Drummer();

  bool joined = false;
  List<JamImageCard> jamImageCards = [];
  List<Jam> jams = [];
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_PRIMARY_DARK,
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  if (band?.name != null)
                    Container(
                      height: 375,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            imageUrl:modifyImageUrl(band?.url ?? "","100x100"),//widget.band?.imageUrl ?? "",
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorWidget: (context, url, error) {
                              return Container(color: Colors.grey.shade900);
                            },
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black]),
                            ),
                          ).frosted(blur: 6, frostColor: Colors.black),
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl:modifyImageUrl(band?.url ?? "","500x500"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // SafeArea(
                          //     child: Container(
                          //         alignment: Alignment.topCenter,
                          //         child: Text(
                          //           "${band?.category}",
                          //           textAlign: TextAlign.center,
                          //           style: const TextStyle(
                          //               fontSize: 24,
                          //               fontWeight: FontWeight.bold),
                          //         ))),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          AutoSizeText(
                                            "${band?.name}",
                                            maxFontSize: 42,
                                            minFontSize: 24,
                                            style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: APP_FONT_BOLD,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 4,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      if (drummer != null)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserProfilePage(
                                                    drummer: drummer,
                                                    fromSearch: true,
                                                  ),
                                                ));
                                          },
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Founded by",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: APP_FONT_MEDIUM,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.white54),
                                              ),
                                              Text(
                                                " @${drummer?.username}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: APP_FONT_MEDIUM,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      //Text("${widget.band?.badges}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 12,
                  ),

                  Wrap(
                    runSpacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.spaceBetween,
                    spacing: 4,
                    alignment: WrapAlignment.spaceEvenly,
                    children: categoryList.map(
                          (hook) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 12),
                            decoration: BoxDecoration(
                              color: COLOR_PRIMARY_DARK,
                              border: Border.all(color: Colors.grey.shade900,width: 1.25),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(hook,style: const TextStyle(color: Colors.white,fontFamily: APP_FONT_MEDIUM),),
                          ),
                    ).toList(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: memberCards,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ExpandableText(
                      band?.description ?? "",
                      expandText: 'show more',
                      collapseText: 'show less',
                      maxLines: 2,
                      linkColor: Colors.blue,
                      style: const TextStyle(
                        fontFamily: APP_FONT_LIGHT,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (!joined)
                    GestureDetector(
                      onTap: () {
                        joinBand();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          "Join the Band",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if(band?.foundedBy==FirebaseAuth.instance.currentUser?.uid)
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBand(
                              band: widget.band??Band(),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: COLOR_PRIMARY_DARK,
                                borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade900,width: 3),
                            ),
                            child: Row(
                              children: [
                                Text(
                                    "Edit"
                                ),
                                SizedBox(width: 8,),
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  if (joined)
                    GestureDetector(
                      onTap: () {
                        leaveBand();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          "Joined",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (joined)
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          "images/drumm_logo.png",
                          height: 32,
                          color: Colors.white,
                        )),
                  const SizedBox(
                    height: 12,
                  ),
                  if (joined)
                    Container(
                      padding: const EdgeInsets.all(1),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          // color: (jamImageCards.isNotEmpty)
                          //     ? COLOR_PRIMARY_DARK
                          //     : Colors.black,
                          color: COLOR_PRIMARY_DARK,
                          border: Border(
                            top: BorderSide(
                              color: Colors.white24,
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
                          if (jamImageCards.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: GridView.count(
                                  childAspectRatio: 1,
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 6, // Number of columns
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  crossAxisSpacing: 6,
                                  children: jamImageCards),
                            ),
                          if (jamImageCards.isEmpty)
                            Container(
                              height: 200,
                              color: COLOR_PRIMARY_DARK,
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: Text(
                                    "There are currently no active drumms",style: TextStyle(
                                  fontFamily: APP_FONT_LIGHT,
                                ),),
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
            if (joined)
              Container(
                width: double.infinity,
                alignment: /*jamImageCards.isNotEmpty ?*/
                    Alignment.bottomCenter, //:Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconLabelButton(
                      label: 'Join Open Drumm',
                      onPressed: () {
                        Jam jam = Jam();
                        jam.broadcast = false;
                        jam.title = widget.band?.name;
                        jam.bandId = widget.band?.bandId;
                        jam.jamId = widget.band?.bandId;
                        jam.articleId = widget.band?.bandId;
                        jam.lastActive = Timestamp.now();
                        jam.startedBy = "";
                        jam.imageUrl = widget.band?.url;
                        jam.count = 0;
                        jam.membersID=[];
                        //FirebaseDBOperations.createOpenDrumm(jam);
                        FirebaseDBOperations.addMemberToJam(
                                jam.jamId ?? "",
                                FirebaseAuth.instance.currentUser?.uid ?? "",
                                true)
                            .then((value) {
                          print("Added the member ${value}");
                          if (!value) {
                            FirebaseDBOperations.createOpenDrumm(jam);
                          }
                          FirebaseDBOperations.sendNotificationToTopic(jam,false,true);
                        });

                        Navigator.pop(context);
                        try{
                          Navigator.pop(ConnectToChannel.jamRoomContext);
                        }catch(e){

                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: COLOR_PRIMARY_DARK,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(0.0)),
                                child: JamRoomPage(
                                  jam: jam,
                                  open: true,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      imageAsset: 'images/drumm_logo.png',
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        print('Ask a question');
                        Navigator.pop(context);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: COLOR_PRIMARY_DARK,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(0.0)),
                                child: CreateJam(
                                    title: widget.band?.name,
                                    bandId: widget.band?.bandId,
                                    imageUrl: widget.band?.url),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        child: const Icon(Icons.add),
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(COLOR_PRIMARY_VAL)),
                      ),
                    )
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: GestureDetector(
                    onTap: (){
                      Vibrate.feedback(FeedbackType.selection);
                      generateLink();
                    },
                    child:  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ShareWidget(
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool showBandsAlert = sharedPref.getBool(ALERT_EXPLORE_BANDS_SHARED_PREF)??true;
    if(showBandsAlert) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return TutorialBox(
            boxType: BOX_TYPE_ALERT,
            autoUpdate: true,
            sharedPreferenceKey: ALERT_EXPLORE_BANDS_SHARED_PREF,
            tutorialImageAsset: "images/team_active.png",
            tutorialMessage: TUTORIAL_MESSAGE_BANDS,
            tutorialMessageTitle: TUTORIAL_MESSAGE_BANDS_TITLE,
          );
        },
      );
    }
  }


  void generateLink() async {
    Band? linkBand = band;
    linkBand?.creationTime = null;

    metadata = BranchContentMetaData()..addCustomMetadata('band', linkBand?.toJson());

    print("Band url is: ${band?.url}");

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        //canonicalUrl: 'https://flutter.dev',
        title: "Join the \"${band?.name}\" Band",
        imageUrl: modifyImageUrl(linkBand?.url ?? "","500x500")??DEFAULT_APP_IMAGE_URL,
        contentDescription: 'Drumm - News & Conversations',
        contentMetadata: metadata,
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');

    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

    if (response.success) {
      //if (context.mounted) {
      print('GeneratedLink : ${response.result}');

      String topic = "";
      int index = 0;
      for(String category in categoryList){
        if(topic == "")
            topic = category;
        else if(index == categoryList.length-1)
          topic = topic + ", and ${category}";
        else
          topic = topic +", ${category}";
          index+=1;
      }
      String bandLink =
          "Tap the link to checkout the band \"${linkBand?.name}\" on the Drumm app, and stay synced with latest news, updates and live audio conversations on ${topic}.\n\n${response.result}";

      Share.share(bandLink);

      // await Clipboard.setData(ClipboardData(text: response.result)).then((value) {
      // });

      // }
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    band = widget.band;
    setState(() {
      categoryList = List<String>.from(band?.hooks??[]);
    });
    print("Band hooks ${band?.hooks?.elementAt(0)}");
    checkIfUserisMember();
    getJams(widget.band?.bandId);
    getDrummer(widget.band?.foundedBy ?? "");
    getMembers();
    getSharedPreferences();
  }

  void getJams(String? uid) async {
    List<Jam> fetchedJam =
        await FirebaseDBOperations.getJamsFromBand(uid ?? ""); //getUserBands();
    jams = fetchedJam;

    setState(() {
      jamImageCards = jams.map((_jam) {
        return JamImageCard(_jam);
      }).toList();
    });
  }

  void getMembers() async {
    List<Drummer> drummers =
        await FirebaseDBOperations.getUsersByBand(widget.band ?? Band());

    setState(() {
      memberCards = drummers.map((e) {
        return Container(
          padding: const EdgeInsets.all(2),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      fromSearch: true,
                      drummer: e,
                    ),
                  ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                  width: 36,
                  height: 36,
                  imageUrl: modifyImageUrl(e.imageUrl ?? "","100x100"),
                  fit: BoxFit.cover),
            ),
          ),
        );
      }).toList();
    });
  }

  void getDrummer(String foundedBy) {
    FirebaseDBOperations.getDrummer(foundedBy).then((value) {
      setState(() {
        drummer = value;
      });
    });
  }

  void joinBand() async {
    bool status = await FirebaseDBOperations.joinBand(widget.band);
    setState(() {
      if (status) joined = true;
    });
  }

  void leaveBand() async {
    bool status = await FirebaseDBOperations.leaveBand(widget.band);
    setState(() {
      if (status) joined = false;
    });
  }

  void checkIfUserisMember() async {
    bool status = await FirebaseDBOperations.haveJoinedBand(widget.band);
    setState(() {
      joined = status;
    });
  }
}
