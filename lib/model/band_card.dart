import 'package:flutter/material.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/question.dart';

import '../view_band.dart';
import 'band.dart';

typedef void BandCallback(String bandID);

class BandCard extends StatelessWidget {
  final Band band;
  bool? onlySelectable = true;
  BandCallback? bandCallback;

  BandCard(this.band, {Key? key, this.onlySelectable,this.bandCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!onlySelectable!) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewBand(
                  band: band,
                ),
              ));
        }
        else {
          bandCallback!(band.bandId??"");
        }
      },
      child: Container(
        margin: EdgeInsets.all(4),
        width: 250,
        color: Colors.grey.shade900,
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*0.75,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                ),
                child: Text(
                  "${band.name}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            if (true)
              Container(
                color: Colors.cyan,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${band.count} members",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            if (true)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Founded by ${band.foundedBy}",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
