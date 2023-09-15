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
import 'package:drumm_app/model/people_card.dart';
import 'package:drumm_app/search_page.dart';
import 'package:drumm_app/search_result_page.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String query = "";
  List<BandCard> bandCards = [];
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
    getArticles();
    //getUserBands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getArticles() async {
    if(FirebaseDBOperations.exploreArticles.isEmpty) {
      List<Article> fetchedArticles = await FirebaseDBOperations.searchArticles(
          query ?? ""); //getUserBands();
      articles = fetchedArticles;
    }
    else {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SearchResultPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Wrap(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(2)),
                      child: Row(
                        children: [Icon(Icons.search), Text("Search")],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (articleCards.length > 0)
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: GridView.custom(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      repeatPattern: QuiltedGridRepeatPattern.inverted,
                      pattern: [
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(1, 2),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(1, 2),
                      ],
                    ),
                    childrenDelegate: (articleCards.length > 0)?SliverChildBuilderDelegate(
                      childCount: articleCards.length,
                      (context, index) => articleCards.elementAt(index),
                    ):SliverChildBuilderDelegate(
                        (context, index) => Container(color: Colors.grey.shade900,),
                  ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
