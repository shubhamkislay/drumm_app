import 'package:flutter/material.dart';
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
import 'package:drumm_app/model/people_card.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAppBarExpanded = true;

  String query = "";
  List<BandImageCard> bandCards = [];
  List<Band> bands = [];

  List<PeopleCard> peopleCards = [];
  List<Drummer> people = [];

  List<ArticleImageCard> articleCards = [];
  List<Article> articles = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    //getUserBands();
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
      peopleCards = people.map((drummer) => PeopleCard(drummer)).toList();
    });
  }

  void getArticles() async {
    List<Article> fetchedArticles = await FirebaseDBOperations.searchArticles(
        query ?? "",0); //getUserBands();
    articles = fetchedArticles;
    setState(() {
      articleCards = articles.map((article) => ArticleImageCard(article)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.grey.shade900,
              title: const Text(
                'Search',
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.left,
              ),
              centerTitle: false,
              pinned: true,
              floating: true,
              expandedHeight: 175,
              bottom: PreferredSize(
                preferredSize: const Size(100, 123),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0)),
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          hintText: 'type here...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
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
                          // Perform search based on the entered value
                        },
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.blue,
                      onTap: (idx) {
                        index = idx;
                      },
                      tabs: [
                        const Tab(text: 'Articles'),
                        const Tab(text: 'People'),
                        const Tab(text: 'Bands'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              gridDelegate: SliverQuiltedGridDelegate(
                                crossAxisCount: 3,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                repeatPattern: QuiltedGridRepeatPattern.inverted,
                                pattern: [
                                  const QuiltedGridTile(2, 1),
                                  const QuiltedGridTile(2, 2),
                                  const QuiltedGridTile(1, 2),
                                  const QuiltedGridTile(2, 1),
                                  const QuiltedGridTile(1, 2),
                                ],
                              ),
                              childrenDelegate: SliverChildBuilderDelegate(
                                childCount: articleCards.length,
                                    (context, index) => articleCards.elementAt(index),
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
                            padding: const EdgeInsets.all(12.0),
                            child: GridView.count(
                                childAspectRatio: 1,
                                crossAxisCount: 2, // Number of columns
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                crossAxisSpacing: 12,
                                children: peopleCards),
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
                            padding: const EdgeInsets.all(12.0),
                            child: GridView.count(
                                childAspectRatio: 1,
                                crossAxisCount: 2, // Number of columns
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                crossAxisSpacing: 12,
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
    );
  }
}
