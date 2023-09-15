import 'package:flutter/material.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';

import 'create_band.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/band.dart';

class BandSearchResult extends StatefulWidget {
  @override
  State<BandSearchResult> createState() => BandSearchResultState();

  String? query;

  BandSearchResult({Key? key, required this.query}) : super(key: key);
}

class BandSearchResultState extends State<BandSearchResult> {

  List<BandImageCard> cards = [];
  List<Band> bands = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(cards.isNotEmpty)Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                      childAspectRatio: 1,
                      crossAxisCount: 2, // Number of columns
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      crossAxisSpacing: 12,
                      children: cards
                  ),
                ),
                const SizedBox(height: 100,),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void getUserBands() async {
    List<Band> fetchedBands =
    await FirebaseDBOperations.getUserBands(widget.query??"");//getUserBands();
    bands = fetchedBands;
    setState(() {
      cards = bands.map((band) => BandImageCard(band,onlySelectable: false,)).toList();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserBands();
  }
}
