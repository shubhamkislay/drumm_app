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

class SearchResultPage extends StatefulWidget {
  @override
  SearchResultPageState createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage>
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
    _tabController = TabController(length: 3, vsync: this);
    getArticles();
    getUserBands();
    getPeople();
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

  void getPeople() async {
    List<Drummer> fetchedPeople =
        await FirebaseDBOperations.getPeople(query ?? ""); //getUserBands();
    people = fetchedPeople;
    setState(() {
      peopleCards = people.map((drummer) => DrummerImageCard(drummer)).toList();
    });
  }

  void getArticles() async {
    if (FirebaseDBOperations.exploreArticles.isEmpty || query != "") {
      List<Article> fetchedArticles = await FirebaseDBOperations.searchArticles(
          query ?? "",0); //getUserBands();
      articles = fetchedArticles;
    } else {
      articles = FirebaseDBOperations.exploreArticles;
    }
    setState(() {
      articleCards =
          articles.map((article) => ArticleImageCard(article,articles: articles,)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                      child: const Icon(Icons.delete_forever_rounded)),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  controller: textEditingController,
                                  scrollPadding: EdgeInsets.zero,
                                  decoration: InputDecoration(
                                    hintText: "Search...",
                                      isDense: true,
                                      prefixIcon: null,
                                      filled: false,
                                      fillColor: Colors.grey.shade900,
                                      contentPadding: const EdgeInsets.all(0)),
                                  onChanged: (value) {
                                    setState(() {
                                      inputText = value;
                                      if (value.length >= 3) {
                                        query = value;
                                        if (index == 2)
                                          getUserBands();
                                        else if (index == 1)
                                          getPeople();
                                        else
                                          getArticles();
                                        print(query);
                                      } else if (value.length < 3) {
                                        if (query != "") {
                                          query = "";
                                          if (index == 1)
                                            getUserBands();
                                          else if (index == 0)
                                            getPeople();
                                          else
                                            getArticles();
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
            if (true)
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                onTap: (idx) {
                  index = idx;
                },
                tabs: const [
                  Tab(text: 'Articles'),
                  Tab(text: 'People'),
                  Tab(text: 'Bands'),
                ],
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Scaffold(
                    backgroundColor: Colors.black,
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (articleCards.isNotEmpty)
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: GridView.custom(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                    gridDelegate: SliverQuiltedGridDelegate(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      repeatPattern:
                                          QuiltedGridRepeatPattern.inverted,
                                      pattern: [
                                        const QuiltedGridTile(1, 1),
                                        const QuiltedGridTile(2, 2),
                                        const QuiltedGridTile(1, 1),

                                        //grid 2
                                        const QuiltedGridTile(1, 2),
                                        const QuiltedGridTile(1, 1),
                                        const QuiltedGridTile(1, 1),
                                        const QuiltedGridTile(1, 2),

                                        //grid 3
                                        const QuiltedGridTile(2, 3),

                                        //grid 4
                                        const QuiltedGridTile(1, 1),
                                        const QuiltedGridTile(2, 2),
                                        const QuiltedGridTile(1, 1),
                                      ],
                                    ),
                                    childrenDelegate:
                                        SliverChildBuilderDelegate(
                                      childCount: articleCards.length,
                                      (context, index) =>
                                          articleCards.elementAt(index),
                                    ),
                                  ),
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
                  // People results
                  Scaffold(
                    backgroundColor: Colors.black,
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (peopleCards.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GridView.count(
                                      childAspectRatio: 1,
                                      crossAxisCount: 2, // Number of columns
                                      mainAxisSpacing: 3,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 4),
                                      crossAxisSpacing: 3,
                                      children: peopleCards),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bands results
                  Scaffold(
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
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 4),
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      children: bandCards),
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
                  // News results
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
