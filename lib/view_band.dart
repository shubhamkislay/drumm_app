import 'package:flutter/material.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/jam_card.dart';
import 'package:drumm_app/model/jam_image_card.dart';

class ViewBand extends StatefulWidget {
  final Band band;
  ViewBand({Key? key, required this.band}) : super(key: key);

  @override
  State<ViewBand> createState() => ViewBandState();
}

class ViewBandState extends State<ViewBand> {
  List<JamImageCard> cards = [];
  List<Jam> jams = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            height: 275,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(24, 100, 75, 24),
                  child: Stack(
                    children: [
                      Text(
                        "${widget.band.name}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    "${widget.band.count} Members",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "Founded by ${widget.band.foundedBy}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "Description",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  child: Text(
                    "${widget.band.description}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    "Live jams",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                if (cards.isEmpty)Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cards.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        child: cards[index],
                      );
                    },
                  ),
                ),
                if (cards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GridView.count(
                      childAspectRatio: 1,
                      crossAxisCount: 2,
                      mainAxisSpacing: 3,// Number of columns
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0),
                      crossAxisSpacing: 3,
                      children: cards),
                ),
                SizedBox(
                  height: 150,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.symmetric(horizontal: 48.0, vertical: 32),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              onPressed: () {
                // Add your logic here
                print('Ask a question');

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                        child: CreateJam(
                            bandId: widget.band.bandId, articleId: "none",imageUrl: widget.band.url,),
                      ),
                    );
                  },
                );
              },
              label: Text(
                'Start a jam',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(
                Icons.groups,
                color: Colors.blue,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getUserJams() async {
    List<Jam> fetchedJams =
        await FirebaseDBOperations.getJamsFromBand(widget.band.bandId ?? "");
    jams = fetchedJams;
    setState(() {
      cards = jams.map((jam) => JamImageCard(jam)).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserJams();
  }
}
