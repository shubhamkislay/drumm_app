import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                              width: 175,
                              height: 175,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl:modifyImageUrl(band?.url ?? "","300x300"),
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
                                      AutoSizeText(
                                        "${band?.name}",
                                        maxFontSize: 42,
                                        minFontSize: 24,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: "alata",
                                            fontWeight: FontWeight.bold),
                                        maxLines: 4,
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
                                              Text(
                                                "Founded by",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: "alata",
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.white54),
                                              ),
                                              Text(
                                                " @${drummer?.username}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      //Text("${widget.band?.badges}"),
                                    ],
                                  ),
                                  if (false)
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            "${band?.count}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Icon(
                                            Icons.people,
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    )
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
                            padding: EdgeInsets.symmetric(vertical: 4,horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              border: Border.all(color: Colors.grey.shade800,width: 1.25),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(hook,style: TextStyle(color: Colors.white,fontFamily: "alata"),),
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
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "Join the Band",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (joined)
                    GestureDetector(
                      onTap: () {
                        leaveBand();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
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
                      decoration: BoxDecoration(
                          // color: (jamImageCards.isNotEmpty)
                          //     ? COLOR_PRIMARY_DARK
                          //     : Colors.black,
                          color: COLOR_PRIMARY_DARK,
                          border: const Border(
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
                              child: Center(
                                child: Text(
                                    "There are currently no active drumms"),
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
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 32),
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
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: COLOR_PRIMARY_DARK,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
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
                    SizedBox(width: 8),
                    Text("or"),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        print('Ask a question');
                        Navigator.pop(context);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: COLOR_PRIMARY_DARK,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
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
                        child: Icon(Icons.add),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(COLOR_PRIMARY_VAL)),
                      ),
                    )
                  ],
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<JamImageCard> jamImageCards = [];
  List<Jam> jams = [];

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
    getBands(widget.band?.bandId);
    getDrummer(widget.band?.foundedBy ?? "");
    getMembers();
  }

  void getBands(String? uid) async {
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
          padding: EdgeInsets.all(2),
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
