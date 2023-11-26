import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/bands_search_result.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/article_card.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/band_card.dart';
import 'package:drumm_app/model/band_image_card.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
import 'package:drumm_app/model/people_card.dart';
import 'package:drumm_app/search_page.dart';
import 'package:lottie/lottie.dart';

class ExploreBandsPage extends StatefulWidget {
  @override
  ExploreBandsPageState createState() => ExploreBandsPageState();
}

class ExploreBandsPageState extends State<ExploreBandsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAppBarExpanded = true;
  TextEditingController textEditingController = TextEditingController();

  String query = "";
  List<BandImageCard> bandCards = [];
  List<Band> bands = [];

  List<DrummerImageCard> peopleCards = [];
  List<Drummer> people = [];

  List<ArticleImageCard> articleCards = [];
  List<Article> articles = [];

  int index = 0;

  String inputText = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    getUserBands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getUserBands() async {
    List<Band> fetchedBands =
        await FirebaseDBOperations.getUserBands(query ?? ""); //getUserBands();
    bands = fetchedBands;
    setState(() {
      bandCards = bands
          .map((band) => BandImageCard(
                band,
                onlySelectable: false,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: AutoSizeText(
                  "Explore Bands",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'alata',
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Image.asset(
                          "images/back.png",
                          color: Colors.white,
                          height: 24,
                        ),
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                      child: Wrap(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(2)),
                            child: Row(
                              children: [
                                (inputText.isEmpty)
                                    ? const Icon(Icons.search)
                                    : GestureDetector(
                                        onTap: () {
                                          textEditingController.text = "";
                                          setState(() {
                                            inputText = "";
                                          });
                                        },
                                        child: const Icon(
                                            Icons.delete_forever_rounded)),
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: TextField(
                                    autofocus: false,
                                    controller: textEditingController,
                                    scrollPadding: EdgeInsets.zero,
                                    decoration: InputDecoration(
                                        hintText: "Search...",
                                        isDense: true,
                                        prefixIcon: null,
                                        filled: false,
                                        fillColor: Colors.grey.shade900,
                                        contentPadding:
                                            const EdgeInsets.all(0)),
                                    onChanged: (value) {
                                      setState(() {
                                        inputText = value;
                                        if (value.length >= 3) {
                                          query = value;
                                          getUserBands();
                                        } else if (value.length < 3) {
                                          if (query != "") {
                                            query = "";
                                            getUserBands();
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.black,
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bandCards.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: GridView.count(
                                    childAspectRatio: 0.8,
                                    crossAxisCount: 2, // Number of columns
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    children: bandCards),
                              ),
                            if (bandCards.isEmpty)
                              Center(
                                child: Container(
                                    child: Lottie.asset('images/lottie_pulse.json',
                                        fit: BoxFit.contain, width: double.maxFinite)),
                              ),
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
