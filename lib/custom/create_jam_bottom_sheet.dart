import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class CreateJam extends StatefulWidget {
  String? articleId;
  String? bandId;
  String? title;
  String? imageUrl;

  CreateJam({Key? key, this.bandId, this.articleId, this.title, this.imageUrl})
      : super(key: key);

  @override
  State<CreateJam> createState() => _CreateJamState();
}

class _CreateJamState extends State<CreateJam> {
  List<BandImageCard> cards = [];
  List<Band> bands = [];
  late String? selectBandID;
  String jamTitle = "";
  late TextEditingController _textEditingController;
  Jam jam = Jam();
  Band? selectedband = null;

  List<BandImageCard> resetList = [];
  @override
  Widget build(BuildContext context) {
    DocumentReference jamRef =
        FirebaseFirestore.instance.collection("jams").doc();
    String pushId = jamRef.id;

    jam.broadcast = false;
    jam.jamId = pushId;
    jam.articleId = this.widget.articleId;
    jam.imageUrl = this.widget.imageUrl;
    jam.title = widget.title == null ? null : '${widget.title}';
    jam.bandId = this.widget.bandId;
    jam.count = 0;
    jam.startedBy = FirebaseAuth.instance.currentUser?.uid;
    jam.membersID = [];

    return SafeArea(
      bottom: false,
      child: Wrap(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Start a Drumm",
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )),
                Row(
                  children: [
                    if(jamTitle.length>0) GestureDetector(
                      onTap: (){
                        setState(() {
                          _textEditingController.text="";
                          jamTitle = "";
                        });
                      },
                      child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.clear,size: 30,)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: TextField(
                          controller: _textEditingController,
                          onChanged: (val) {
                            print("c $val");

                            setState(() {
                              //print("$val");
                              jamTitle = val;
                              jam.title = val;
                              print("Jam Title jamTitle:    ${jamTitle}");
                            });
                          },
                          maxLines: 1,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "What do you want to drumm about?",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (cards.isNotEmpty)// && widget.bandId == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (selectedband != null) Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white38)),
                        child: Stack(

                          children: [
                              Container(
                                  height: 100,
                                  width: 100,
                                  child: BandImageCard(
                                    selectedband!,
                                    onlySelectable: true,
                                  )),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedband = null;
                                  selectBandID = null;
                                });
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                  height: 100,
                                  width: 100,
                                  child: Icon(Icons.cancel_rounded,size: 30,)),
                            )
                          ],
                        ),
                      ),
                      if (selectedband == null) Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          "Select a band you want to drumm with",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      if (selectedband == null) Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.all(0.0),
                        child: GridView.count(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            mainAxisSpacing: 6, // Number of columns
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(left: 2,right: 2,bottom: 36),
                            crossAxisSpacing: 6,
                            children: cards),
                      ),
                    ],
                  ),
                if (selectedband != null) SafeArea(
                  child: Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: IconLabelButton(
                        label: 'Start Drumming',
                        onPressed: () {
                          // Add your logic here
                          int titleLen =
                              jamTitle.length; //jam.title?.length ?? 0;
                          String? title = jamTitle;

                          print("$title");

                          if (titleLen < 3) {
                            AnimatedSnackBar.material(
                              'Title Should have atleast 3 characters',
                              type: AnimatedSnackBarType.warning,
                              mobileSnackBarPosition: MobileSnackBarPosition.bottom
                            ).show(context);
                          } else if (selectBandID == null) {
                            AnimatedSnackBar.material(
                              'Select a band to start drumming',
                              type: AnimatedSnackBarType.error,
                              mobileSnackBarPosition: MobileSnackBarPosition.bottom
                            ).show(context);
                          } else {
                            jam.bandId = selectBandID;
                            jam.title = jamTitle;
                            print("Jam Finale Title:    ${jamTitle}");
                            Jam createJam = Jam();
                            createJam.title = jamTitle;
                            createJam.broadcast = jam.broadcast;
                            createJam.startedBy = jam.startedBy;
                            String url = jam.imageUrl??"";
                            createJam.imageUrl = (url.length>0) ? jam.imageUrl:selectedband?.url;//jam.imageUrl;
                            createJam.articleId = jam.articleId;
                            createJam.membersID = jam.membersID;
                            createJam.bandId = selectBandID;
                            createJam.count = jam.count;
                            createJam.jamId = jam.jamId;

                            print("createJam ${createJam.jamId}");

                            FirebaseDBOperations.createJamData(createJam);
                            FirebaseDBOperations.sendNotificationToTopic(createJam,false,false);
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
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(0.0)),
                                    child: JamRoomPage(
                                      jam: createJam,
                                      open: false,
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          print('Start');
                        },
                        imageAsset: 'images/drumm_logo.png',
                        height: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getUserBands() async {
    List<Band> fetchedBands = await FirebaseDBOperations.getBandByUser();
    bands = fetchedBands;
    setState(() {
      resetList = bands
          .map((band) => BandImageCard(
                band,
                onlySelectable: true,
                bandCallback: (band) {
                  setState(() {
                    selectedband = band;
                    selectBandID = band.bandId;
                  });
                },
              ))
          .toList();
      cards = resetList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectBandID = widget.bandId;
    jamTitle = widget.title == null ? '' : '${widget.title}';
    _textEditingController = TextEditingController(text: jamTitle);
    //if (widget.bandId == null)
      getUserBands();

    if(selectBandID!=null)
      getUserBand();

  }

  void getUserBand() async{
    print("Checking user band");
    String bandID = selectBandID??"";
    if(bandID.length>0) {
      Band band = await FirebaseDBOperations.getBand(selectBandID ?? "");
      setState(() {
        selectedband = band;
        selectBandID = band.bandId;
        print("Band is selected............. ${band.bandId}");
      });
    }


  }
}
