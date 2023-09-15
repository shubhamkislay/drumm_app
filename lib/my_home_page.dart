import 'dart:async';
import 'dart:convert';

import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/drumm_app_bar.dart';
import 'package:drumm_app/custom/helper/remove_duplicate.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/news_model.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/recommender.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';

import 'custom/helper/AudioChannelWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

String getCurrentUserID() {
  final User? user = FirebaseAuth.instance.currentUser;
  final String userID = user?.uid ?? '';
  return userID;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.themeManager,
      required this.analytics,
      required this.observer,
      required this.scrollController});
  final String title;
  final ThemeManager themeManager;
  final ScrollController scrollController;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin<MyHomePage> {
  NewsModel newModel = NewsModel();
  NewsModel headlinesModel = NewsModel();
  List<Object> questionsAsked = [];
  List<Article> articles = [];

  final Duration _debounceDuration = Duration(milliseconds: 100);

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument = null;
  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>();
  int _currentPage = 0;
  int _pageSize = 25; // Number of documents to fetch per page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container(
                //   width: double.maxFinite,
                //   padding: EdgeInsets.only(
                //       top: AppBar().preferredSize.height +
                //           MediaQuery.of(context).padding.top +
                //           60, //120,
                //       bottom: 0,
                //       left: 16 //62 + MediaQuery.of(context).padding.bottom,
                //       ),
                //   child: Row(
                //     children: [
                //       Text(
                //         "Headlines",
                //         textAlign: TextAlign.left,
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           fontSize: 24,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   alignment: AlignmentDirectional.centerStart,
                //   padding: const EdgeInsets.only(left: 8),
                //   child: SizedBox(height: 250, child: listDemoHorizontal()),
                // ),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                      top: AppBar().preferredSize.height +
                          MediaQuery.of(context).padding.top +
                          60, //120,
                      bottom: 0,
                      left: 16 //62 + MediaQuery.of(context).padding.bottom,
                      ),
                  child: Text(
                    "Recommended for You",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child:
                        SizedBox(child: getArticles()), //listDemoVertical()),
                  ),
                ),
              ],
            ),
          ),
        ),
        DrummAppBar(
          scrollController: widget.scrollController,
          titleText: 'Drumm',
          scrollOffset: 100,
          isDark: widget.themeManager.themeMode == ThemeMode.dark, onPressed: () {  }, iconColor: Colors.white.withOpacity(0.25), autoJoinDrumms: false,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  widget.themeManager.themeMode == ThemeMode.dark
                      ? Colors.black
                      : Colors.white,
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )),
            ),
          ],
        )
      ]),
    );
  }

  Future<void> _refreshData() async {
    // Simulate a delay
    getArticlesData(true);
    await Future.delayed(Duration(seconds: 2));
    // Refresh your data
    //getNews();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
    return true;
  }

  Widget listDemoHorizontal() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (newModel == null) {
          return const SizedBox();
        } else {
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: 12,
              bottom: 0, //62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount:
                20, //newModel.totalResults! > 10 ? 10:newModel.totalResults,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              //widget.animationController.forward();
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.withOpacity(0.15)
                      //color: Colors.orange[colorCodes[index]],
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    height: 0,
                    width: 200,
                    child: Center(
                        child: Text(
                      '${headlinesModel.articles?.elementAt(index).title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget getArticles() {
    return StreamBuilder<List<Article>>(
      stream: _articlesController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            child: Text("No data"),
          );
        } else {
          List<Article>? artcls = snapshot.data;
          artcls = RemoveDuplicate.removeDuplicateArticles(artcls!);
          articles = artcls!;

          print("Size of the articles ${artcls.length}");

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: 0, // +120,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: artcls?.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              //widget.animationController.forward();
              return GestureDetector(
                onTap: () {
                  //_sendAnalyticsEvent();
                  debugPrint("Tapped list item");
                  print(
                      "Id of the article ${artcls?.elementAt(index).articleId}");
                  print(
                      "Category of the article ${artcls?.elementAt(index).category}");
                  print(
                      "publishedAt of the article ${artcls?.elementAt(index).publishedAt}");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenArticlePage( article: Article(),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          // begin: const FractionalOffset(0.0, 0.0),
                          // end: const FractionalOffset(1.0, 0.0),
                          // stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                      //color: Colors.orange[colorCodes[index]],
                    ),
                    height: 700,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 150),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                            height: double.maxFinite,
                            imageUrl: artcls?.elementAt(index).imageUrl ?? "",
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Transform.scale(
                              scale: 0.7, // Adjust the scale factor as needed
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                strokeWidth:
                                    4.0, // Adjust the strokeWidth as needed
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              color: Color(COLOR_PRIMARY_VAL),
                              width: 35,
                              "images/logo_background_white.png",
                              height: 35,
                            ),
                          ),
                        ),
                        Container(
                          alignment: AlignmentDirectional.bottomCenter,
                          padding: const EdgeInsets.fromLTRB(24, 16, 64, 42),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.80),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                // begin: const FractionalOffset(0.0, 0.0),
                                // end: const FractionalOffset(1.0, 0.0),
                                // stops: [0.0, 1.0],
                                tileMode: TileMode.clamp),
                          ),
                          child: Text('${artcls?.elementAt(index).title}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36)), //entries[index]
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: ArticleChannel(
                            articleID: artcls?.elementAt(index).articleId ?? "", height: 75,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> getArticlesData(bool refresh) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> userInterests = prefs.getStringList('interestList')!;
      print("List of interests as per prefs $userInterests");

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('articles')
          .where('category', whereIn: userInterests)
          //.orderBy("publishedAt",descending: true)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        List<Article> newArticles =
            snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
        _lastDocument =
            snapshot.docs.last; // Save the last document for the next page

        // newArticles = ArticleRecommendationSystem.recommendArticles(
        //     userInterests, newArticles);

        List<Article> updatedArticles;

        if (refresh) {
          updatedArticles = articles + newArticles;
        } else {
          updatedArticles = newArticles + articles;
        }

        // Add the fetched articles to the stream
        _articlesController.add(updatedArticles);

        print('Fetched Articles: ${articles.length}');
      } else {
        print('Nothing found');
      }
    } catch (e) {
      // Handle any potential errors
      print('Error fetching articles: $e');
    }
  }

  Future<void> _sendAnalyticsEvent() async {
    // Only strings and numbers (longs & doubles for android, ints and doubles for iOS) are supported for GA custom event parameters:
    // https://firebase.google.com/docs/reference/ios/firebaseanalytics/api/reference/Classes/FIRAnalytics#+logeventwithname:parameters:
    // https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
    await widget.analytics.logEvent(
      name: "select_content",
      parameters: {
        "content_type": "image",
        "item_id": 123,
      },
    );
  }

  Future<void> searchHeadlinesAPI() async {
    final query = {
      "apiKey": "63c0e404d0c348039be3299765a8d004",
      "country": "in",
    };
    var url = Uri.https('newsapi.org', '/v2/top-headlines', query);
    Map<String, String> header = {'Content-Type': 'application/json'};
    var response = await http.get(url, headers: header);

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      NewsModel headlineResult = NewsModel.fromJson(json);
      // List<dynamic> list = json['choices'];
      // String searchResult = list[0]["text"];
      // debugPrint(searchResult);

      setState(() {
        //searchAPIResult = searchResult;
        headlineResult.articles
            ?.removeWhere((element) => element.source?.id == 'google-news');
        headlinesModel = headlineResult;
        print("Total Headline api Results: ${headlinesModel.totalResults}");
      });

      ///Uncomment below snippets to enable text to speech
      // //_stop();
      // //aws_speak(searchResult);
      // _speak(searchResult);
      // Use the token to join a channel or renew an expiring token
      //setToken(newToken);
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  bool _isDebouncing = false;

  void _handleScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent) {
      if (!_isDebouncing) {
        _isDebouncing = true;
        _currentPage++;
        debugPrint("Current Page $_currentPage");
        getArticlesData(false);

        Timer(_debounceDuration, () {
          _isDebouncing = false;
        });
      }
    }
    final double itemExtent =
        100.0; // Adjust this value based on your item's height
    final int targetIndex = 4; // Index of the item you want to track

    final int firstVisibleIndex =
        (widget.scrollController.offset / itemExtent).floor();
    final int lastVisibleIndex = ((widget.scrollController.offset +
                widget.scrollController.position.viewportDimension) /
            itemExtent)
        .ceil();

    if (targetIndex >= firstVisibleIndex && targetIndex <= lastVisibleIndex) {
      // User has seen the target item
      // Handle your logic here
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // searchNewsAPI();
    //getNews();
    getArticlesData(true);

    //searchHeadlinesAPI();
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _articlesController.close();
    widget.scrollController.removeListener(_handleScroll);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
