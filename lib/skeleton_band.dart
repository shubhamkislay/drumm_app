import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SkeletonBand extends StatefulWidget {
  const SkeletonBand({Key? key}) : super(key: key);

  @override
  State<SkeletonBand> createState() => _SkeletonBandState();
}

class _SkeletonBandState extends State<SkeletonBand> {
  List<Container> containerList = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Stack(
                children: [
                  AutoSizeText(
                    "Live Drumms",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 175,
              padding: EdgeInsets.only(left: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 150,
                      width: 100,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 150,
                      width: 100,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 150,
                      width: 100,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 150,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Stack(
                children: [
                  AutoSizeText(
                    "Your Bands",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 12,right: 12,top: 16),
                child: GridView.count(
                    crossAxisCount: 2, // Number of columns
                    childAspectRatio: 0.8,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: containerList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateList();
  }

  void generateList() {
    for (int i = 0; i < 4; i++) {
      containerList.add(Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey.shade900,
              ),
            ],
          ),
        ),
      ));
    }
  }
}
