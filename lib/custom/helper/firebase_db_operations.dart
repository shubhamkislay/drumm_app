import 'dart:collection';
import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as realtime;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/question.dart';
import 'package:flutter/animation.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../model/AiVoice.dart';
import '../../model/algolia_article.dart';
import '../../model/band.dart';

typedef void UpdateCallback();

typedef void JamCallback(Jam jam);

class FirebaseDBOperations {
  static var listener;
  static late AnimationController ANIMATION_CONTROLLER;
  static YoutubePlayerController youtubeController = YoutubePlayerController(
    initialVideoId: YoutubePlayer.convertUrlToId(
            "https://www.youtube.com/watch?v=d8jFqvDn3o8") ??
        "d8jFqvDn3o8",
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
      controlsVisibleAtStart: false,
    ),
  );

  static Algolia algolia = Algolia.init(
    applicationId: '6GGZ3SNOXT',
    apiKey: '556ea147474872eb56f4fa0d31ad71eb',
  );

  static late OggOpusPlayer OggOpus_Player;

  static List<Article> exploreArticles = [];
  static HashMap<String, String> articleBand = HashMap();

  static DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  static late Query<Map<String, dynamic>> query;
  static List<Band> fetchedBands = [];
  static List<String> bandCategoryList = [];

  static Future<List<Article>> searchArticles(String query, int page) async {
    AlgoliaQuerySnapshot getArticles = await algolia.instance
        .index('articles')
        .setPage(page)
        .setUserToken(FirebaseAuth.instance.currentUser?.uid ?? "")
        .query(query)
        .setHitsPerPage(25)
        .getObjects();

    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));

    if (query.isEmpty) exploreArticles = result;

    return result;
  }
/**
  static Future<AlgoliaArticles> getArticlesFromAlgolia(int page) async {
    //List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();
    String userToken = await FirebaseAuth.instance.currentUser?.uid ?? "";
    List<String> rmvPosts = [];

    List<Band> bandList = await FirebaseDBOperations.getBandByUser();
    List hooks = [];
    for (Band band in bandList) {
      hooks.addAll(band.hooks ?? []);
    }
    List<String> filterStr = [];
    for (String hook in hooks) {
      filterStr.add("category:${hook}");
      //algoliaQuery = algoliaQuery.facetFilter("'category:${hook}'");
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles();
    int arLen = algoliaArticles.articles?.length ?? 0;
    //int page = 0;

    //while(arLen<1 && page<=2) {
    AlgoliaQuery algoliaQuery = algolia.instance
        .index('articles')
        .setFacets(['meta'])
        .setHitsPerPage(7)
        //.query("Youtube")
        .setPage(page)
        .setUserToken(userToken)
        .setDistinct(value: true)
        .setPersonalizationImpact(value: 75)
        .setEnablePersonalization(enabled: true);

    algoliaQuery = algoliaQuery.facetFilter(filterStr);

    AlgoliaQuerySnapshot getArticles = await algoliaQuery.getObjects();
    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));

    // List<Article> filteredList = [];
    // for (Article farticle in result) {
    //   if (!seenPosts.contains(farticle.articleId)) filteredList.add(farticle);
    // }

    algoliaArticles =
        AlgoliaArticles(articles: result, queryID: getArticles.queryID);

    arLen = algoliaArticles.articles?.length ?? 0;

    // if (arLen < 1) {
    //   print("You have seen all articles");
    //   page = page+1;
    // }
    //}

    return algoliaArticles;
  }
    **/

  static Future<AlgoliaArticles> getArticlesData(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();
    List bandCategoryList = [];

    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks ?? []);
    }
    if (fetchedBands.isEmpty) bandCategoryList.add("general");
    query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'in')
        .where('publishedAt', isNotEqualTo: null)
        .orderBy("publishedAt", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }

  static Future<AlgoliaArticles> getBoostedArticlesData(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();
    List bandCategoryList = [];

    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks ?? []);
    }


    DateTime currentTime = DateTime.now();
    DateTime oneDayAgo = currentTime.subtract(Duration(hours: 3));

    if (fetchedBands.isEmpty) bandCategoryList.add("general");
    query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'in')
        .where('boostamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        //.where('boosts', isGreaterThanOrEqualTo: 1)
        .orderBy("boostamp", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }

  static Future<AlgoliaArticles> getArticlesDataForBand(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse,
      Band selectedBand) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;

    List bandCategoryList = [];

    bandCategoryList.addAll(selectedBand.hooks ?? []);

    query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'in')
        .where('publishedAt', isNotEqualTo: null)
        .orderBy("publishedAt", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }

  static Future<AlgoliaArticles> getBoostedArticlesDataForBand(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse,
      Band selectedBand) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;

    List bandCategoryList = [];

    bandCategoryList.addAll(selectedBand.hooks ?? []);

    DateTime currentTime = DateTime.now();
    DateTime oneDayAgo = currentTime.subtract(Duration(hours: 3));

    query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'in')
        .where('boostamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        //.where('boosts', isGreaterThanOrEqualTo: 1)
        .orderBy("boostamp", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }

  static Future<AlgoliaArticles> getRelatedArticlesFromAlgolia(
      String similarQuery) async {
    AlgoliaArticles algoliaArticles = AlgoliaArticles();

    AlgoliaQuery algoliaQuery = algolia.instance.index('articles');

    algoliaQuery.similarQuery(similarQuery);

    AlgoliaQuerySnapshot getArticles = await algoliaQuery.getObjects();

    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));

    algoliaArticles =
        AlgoliaArticles(articles: result, queryID: getArticles.queryID);

    return algoliaArticles;
  }

  static Future<AiVoice> getAiVoice(String doc) async {
    var data = await FirebaseFirestore.instance
        .collection('aivoice')
        .doc(doc)
        .get()
        .onError((error, stackTrace) {
      var data;
      DocumentSnapshot<Map<String, dynamic>> snapshot = data;
      return snapshot;
    });

    return AiVoice.fromSnapshot(data);
  }

  static Future<AlgoliaArticles>
      getArticleFromAlgoliaForPersonalisedNotificaiton() async {
    String userToken = await FirebaseAuth.instance.currentUser?.uid ?? "";
    AlgoliaArticles algoliaArticles = AlgoliaArticles();

    AlgoliaQuery algoliaQuery = algolia.instance
        .index('articles')
        .setFacets(['meta'])
        .setHitsPerPage(1)
        .setUserToken(userToken)
        .setDistinct(value: true)
        .setPersonalizationImpact(value: 75)
        .setEnablePersonalization(enabled: true);

    AlgoliaQuerySnapshot getArticles = await algoliaQuery.getObjects();
    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));

    algoliaArticles =
        AlgoliaArticles(articles: result, queryID: getArticles.queryID);

    return algoliaArticles;
  }

  static Future<AlgoliaArticles> getArticlesByBandHookFromAlgolia(
      Band selectedBand, int page) async {
    //List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();
    String userToken = await FirebaseAuth.instance.currentUser?.uid ?? "";
    List hooks = selectedBand.hooks ?? [];

    AlgoliaQuery algoliaQuery = algolia.instance
        .index('articles')
        .setFacets(['meta'])
        .setHitsPerPage(7)
        //.query("Youtube")
        .setPage(page)
        .setUserToken(userToken)
        .setDistinct(value: true);
    //.setPersonalizationImpact(value: 75)
    //.setEnablePersonalization(enabled: true);

    List<String> filterStr = [];
    for (String hook in hooks) {
      filterStr.add("category:${hook}");
      //algoliaQuery = algoliaQuery.facetFilter("'category:${hook}'");
    }
    //filterStr.add("source:youtube");
    algoliaQuery = algoliaQuery.facetFilter(filterStr);
    //
    // for(String post in seenPosts){
    //   algoliaQuery.setOptionalFilter("objectID:-${post}");
    // }

    AlgoliaQuerySnapshot getArticles = await algoliaQuery.getObjects();

    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));

    // List<Article> filteredList = [];
    // for (Article farticle in result) {
    //   if (!seenPosts.contains(farticle.articleId)) filteredList.add(farticle);
    // }

    AlgoliaArticles algoliaArticles =
        AlgoliaArticles(articles: result, queryID: getArticles.queryID);

    return algoliaArticles;
  }

  static void updateArticle(
      String articleID, Article updatedArticle, UpdateCallback callback) {
    FirebaseFirestore.instance
        .collection("articles")
        .doc(articleID)
        .set(
          updatedArticle.toJson(),
        )
        .then((_) {
      print('Article updated successfully!');
      callback(); // Invoke the callback when the update completes
    }).catchError((error) {
      print('Failed to update article: $error');
    });
  }

  static Future<bool> updateLike(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
        FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("likes")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(articleRef, {
        'likes': FieldValue.increment(1),
        'boosts': FieldValue.increment(1),
        'boostamp': Timestamp.now()
      });
      batch.set(userLikeRef, {'liked': true});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateBoosts(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
    FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("boosts")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(articleRef, {
        'likes': FieldValue.increment(1),
        'boosts': FieldValue.increment(1),
        'boostamp': Timestamp.now()
      });
      batch.set(userLikeRef, {'boosted': true});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateCount(String? jamID, int count) async {
    // final DocumentReference jams =
    //     FirebaseFirestore.instance.collection("openDrumm").doc(jamID);

    final DocumentReference openDrumms =
        FirebaseFirestore.instance.collection("openDrumm").doc(jamID);

    // jams.update({'count': count});
    openDrumms.update({'count': count});
    return true;
  }

  static void updateSummary(String? articleID, String? summary) async {
    FirebaseFirestore.instance
        .collection("articles")
        .doc(articleID)
        .update({'summary': summary ?? ""});
  }

  static void updateReads(String? articleID) async {
    //final DocumentReference articleRef =
    FirebaseFirestore.instance
        .collection("articles")
        .doc(articleID)
        .update({'reads': FieldValue.increment(1)});
  }

  static Future<bool> removeLike(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
        FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("likes")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(articleRef, {
        'likes': FieldValue.increment(-1),
        'boosts': FieldValue.increment(-1),
      });
      batch.delete(userLikeRef);

      await batch.commit();
      return true;
    } catch (error) {
      print("Error removing like status: $error");
      return false;
    }
  }

  static Future<bool> removeBoost(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
    FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("boosts")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(articleRef, {
        'likes': FieldValue.increment(-1),
        'boosts': FieldValue.increment(-1),
      });
      batch.delete(userLikeRef);

      await batch.commit();
      return true;
    } catch (error) {
      print("Error removing like status: $error");
      return false;
    }
  }

  static String getCurrentUserID() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userID = user?.uid ?? '';
    //  print("CurrentUserID is $userID");
    return userID;
  }

  static Future<bool> hasLiked(String? articleID) async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("userActivity")
          .doc(getCurrentUserID())
          .collection("likes")
          .doc(articleID)
          .get();

      return doc.exists;
    } catch (error) {
      print("Error checking like status: $error");
      return false;
    }
  }

  static Future<bool> hasBoosted(String? articleID) async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("userActivity")
          .doc(getCurrentUserID())
          .collection("boosts")
          .doc(articleID)
          .get();

      return doc.exists;
    } catch (error) {
      print("Error checking like status: $error");
      return false;
    }
  }

  static Future<bool> updateSeen(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    // final DocumentReference articleRef =
    // FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("seen")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      // batch.update(articleRef, {'likes': FieldValue.increment(1)});
      batch.set(userLikeRef, {'seen': true});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateJoined(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    // final DocumentReference articleRef =
    // FirebaseFirestore.instance.collection("articles").doc(articleID);
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("joined")
        .doc(articleID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      // batch.update(articleRef, {'likes': FieldValue.increment(1)});
      batch.set(userLikeRef, {'joined': true});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error updating joined status: $error");
      return false;
    }
  }

  static Future<List<String>> fetchSeenList() async {
    final String currentUserID = getCurrentUserID();
    try {
      final QuerySnapshot userSeenSnapshot = await FirebaseFirestore.instance
          .collection("userActivity")
          .doc(currentUserID)
          .collection("seen")
          //.limit(100)
          .get();

      // Extract the list of seen articles from the snapshot
      final List<String> seenArticles = userSeenSnapshot.docs
          .map((DocumentSnapshot doc) =>
              doc.id) // Get the document IDs (article IDs)
          .toList();

      return seenArticles;
    } catch (error) {
      print("Error fetching seen list: $error");
      return [];
    }
  }

  static Future<List<Question>> getMyQuestions() async {
    print("getQuestionsAsked triggered");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    DateTime currentTime = DateTime.now();

    // Calculate the time one minute ago
    DateTime oneDayAgo = currentTime.subtract(Duration(days: 1));
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
        .where('createdTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        //.orderBy('createdTime',descending: true)
        .get();
    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static Future<void> postQuestion(Question question) async {
    try {
      // Get the current user's UID
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not authenticated");
      }

      // Prepare the data to be posted
      Map<String, dynamic> questionData = question.toJson();

      // Post the question to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('questions')
          .doc(question.qid)
          .set(question.toJson())
          .onError(
              (error, stackTrace) => print('Error posting question: $error'));

      print(
          'Question posted successfully Users/$uid/questions/${question.qid} \n ${question.toJson()}');
    } catch (error) {
      print('Error posting question: $error');
      // Handle error as needed
    }
  }

  static Future<List<Question>> getQuestionsAsked() async {
    print("getQuestionsAsked triggered");
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //List<String> userInterests = prefs.getStringList('interestList')!;

    DateTime currentTime = DateTime.now();

    // Calculate the time one minute ago
    DateTime oneDayAgo = currentTime.subtract(Duration(days: 1));

    var data = await FirebaseFirestore.instance
        .collectionGroup('questions')
        .where('createdTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .orderBy('createdTime', descending: true)
        //.where("hook", whereIn: userInterests)
        .get();

    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static Future<List<Drummer>> getBandMembers() async {
    print("getQuestionsAsked triggered");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userInterests = prefs.getStringList('interestList')!;

    var data = await FirebaseFirestore.instance
        .collectionGroup('mybands')
        .where("category", whereIn: userInterests)
        .get();

    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static Future<List<Jam>> getJamsFromBand(String bandId) async {
    print("getJamsFromBand triggered");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('bandId', isEqualTo: bandId)
        .get();
    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      // int memLen = jam.membersID?.length ?? 0;
      if (isTimestampWithin1Minute(jam.lastActive ?? Timestamp.now())) {
        filterList.add(jam);
      }
    }

    return filterList;
  }

  static bool isTimestampWithin1Minute(Timestamp firebaseTimestamp) {
    // Get the current timestamp
    Timestamp currentTimestamp = Timestamp.now();

    // Calculate the difference in milliseconds
    int differenceMilliseconds = currentTimestamp.millisecondsSinceEpoch -
        firebaseTimestamp.millisecondsSinceEpoch;

    // Check if the difference is greater than 2 minutes (120,000 milliseconds)
    if (differenceMilliseconds > 60000) {
      return false;
    } else {
      return true;
    }
  }

  static Future<List<Jam>> getDrummsFromBands() async {
    print("getDrummsFromBands triggered");

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    DateTime currentTime = DateTime.now();

    // Calculate the time one minute ago
    DateTime oneMinuteAgo = currentTime.subtract(Duration(minutes: 1));

    List bandCategoryList = [];
    for (Band band in fetchedBands) {
      //print("${band.name}");
      bandCategoryList.add(band.bandId);
    }
    if (bandCategoryList.isEmpty) return [];

    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('bandId', whereIn: bandCategoryList)
        .where('broadcast', isEqualTo: false)
        .where('lastActive',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneMinuteAgo))
        //.where('lastActive', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
        // .where('count', isGreaterThan: 0)
        .get();

    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));

    print("Jams list size ${fetchedList.length} ///////////////////////// ");
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      //if (isTimestampWithin1Minute(jam.lastActive ?? Timestamp.now())) {
      filterList.add(jam);
      //}
    }
    print("Filtered list size ${filterList.length} ///////////////////////// ");

    return filterList;
  }

  static Future<Jam> getDrummsFromJamId(Jam jam) async {
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .doc(jam.jamId)
        .get();

    Jam fetchedJam = Jam.fromSnapshot(data);

    return fetchedJam;
  }

  static Future<List<Jam>> getOpenDrummsFromBands() async {
    print("getJamsFromBand triggered");

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    List bandCategoryList = [];
    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks as Iterable);
    }
    if (bandCategoryList.isEmpty) {
      print("BandIDList is empty");
      return [];
    }

    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('bandId', whereIn: bandCategoryList)
        .where('broadcast', isEqualTo: false)
        .where('count', isGreaterThan: 0)
        .get();
    // List<Jam> fetchedList =
    //     List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    // List<Jam> filterList = [];
    // for (Jam jam in fetchedList) {
    //   int memLen = jam.membersID?.length ?? 0;
    //   bool isBroadcast = jam.broadcast ?? false;
    //   if (memLen > 0 && !isBroadcast) {
    //     filterList.add(jam);
    //   }
    // }

    List<Jam> fetchedJams =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    List<Jam> filteredJams = [];
    for (Jam liveJam in fetchedJams) {
      if (isTimestampWithin1Minute(liveJam.lastActive ?? Timestamp.now())) {
        filteredJams.add(liveJam);
      }
    }
    return filteredJams;
  }

  // Function to update the "lastActive" field of a document in the "bands" collection
  static Future<void> updateLastActive(String bandId) async {
    try {
      final CollectionReference bandsCollection =
          FirebaseFirestore.instance.collection('openDrumm');

      // Get the current timestamp
      final Timestamp currentTime = Timestamp.now();

      // Update the document with the new "lastActive" timestamp
      await bandsCollection.doc(bandId).update({
        'lastActive': currentTime,
      });

      print('Document updated successfully');
    } catch (error) {
      print('Error updating document: $error');
    }
  }

  static Future<List<Jam>> getJamsFromArticle(String articleId) async {
    print("getJamsFromArticle triggered");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('articleId', isEqualTo: articleId)
        .get();

    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));

    // var opendata = await FirebaseFirestore.instance
    //     .collection('openDrumm')
    //     .where('articleId', isEqualTo: articleId)
    //     .get();
    //
    // fetchedList =
    //     fetchedList + List.from(opendata.docs.map((e) => Jam.fromSnapshot(e)));
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      //int memLen = jam.membersID?.length ?? 0;
      if (isTimestampWithin1Minute(jam.lastActive ?? Timestamp.now())) {
        filterList.add(jam);
      }
    }
    print("fetchedList size: ${fetchedList.length}");

    return filterList;
  }

  static Future<List<Jam>> getBroadcastJams() async {
    print("getBroadcastJams triggered");
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('broadcast', isEqualTo: true)
        .get();

    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    return fetchedList;
  }

  static Future<bool> createBand(Band band) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference bandRef =
        FirebaseFirestore.instance.collection("bands").doc(band.bandId);

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("bands")
        .doc(band.bandId)
        .collection("members")
        .doc(currentUserID);

    final DocumentReference userBandRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("mybands")
        .doc(band.bandId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.set(bandMemRef, {'userId': currentUserID});
      batch.set(bandRef, band.toJson());
      batch.set(userBandRef, {'bandId': band.bandId});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error creating band: $error");
      return false;
    }
  }

  static Future<bool> haveJoinedBand(Band? band) async {
    bool isJoined = false;
    final String currentUserID = getCurrentUserID();

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("mybands")
        .doc(band?.bandId);

    var data = await bandMemRef.get();

    if (data.exists) {
      isJoined = true;
    }

    return isJoined;
  }

  static Future<bool> joinBand(Band? band) async {
    final String currentUserID = getCurrentUserID();

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("bands")
        .doc(band?.bandId)
        .collection("members")
        .doc(currentUserID);

    final DocumentReference bandCountRef =
        FirebaseFirestore.instance.collection("bands").doc(band?.bandId);

    final DocumentReference userBandRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("mybands")
        .doc(band?.bandId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(bandCountRef, {'count': FieldValue.increment(1)});
      batch.set(bandMemRef, {'userId': currentUserID});
      batch.set(userBandRef, {'bandId': band?.bandId});

      await batch.commit();
      FirebaseDBOperations.subscribeToTopic(band?.bandId ?? "");
      return true;
    } catch (error) {
      print("Error joining band: $error");
      return false;
    }
  }

  static Future<bool> leaveBand(Band? band) async {
    final String currentUserID = getCurrentUserID();

    final DocumentReference bandCountRef =
        FirebaseFirestore.instance.collection("bands").doc(band?.bandId);

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("bands")
        .doc(band?.bandId)
        .collection("members")
        .doc(currentUserID);

    final DocumentReference userBandRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("mybands")
        .doc(band?.bandId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(bandCountRef, {'count': FieldValue.increment(-1)});
      batch.delete(bandMemRef);
      batch.delete(userBandRef);

      await batch.commit();
      FirebaseDBOperations.unsubscribeFromTopic(band?.bandId ?? "");
      return true;
    } catch (error) {
      print("Error leaving band: $error");
      return false;
    }
  }

  static Future<List<Band>> getUserBands(String query) async {
    print("getBands triggered");
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    // List<Band> emptyList = [];
    // if (query.length >= 3) {
    //   var data = await FirebaseFirestore.instance
    //       .collection('bands')
    //       .where('name', isGreaterThanOrEqualTo: query)
    //       .where('name', isLessThan: query + '\uf8ff')
    //       // .doc(uid)
    //       // .collection('questions')
    //       //.orderBy('createdTime',descending: true)
    //       .get();
    //   return List.from(data.docs.map((e) => Band.fromSnapshot(e)));
    // } else
    //   return emptyList;

    AlgoliaQuerySnapshot getArticles =
        await algolia.instance.index('bands').query(query).getObjects();

    //print("Getting Articles from Algolia ${getArticles.hits.elementAt(0).data["title"]}");
    List<Band> result = List.from(
        getArticles.hits.map((e) => Band.fromAlgoliaSnapshot(e.data)));

    return result;
  }

  static Future<bool> isFollowing(String? userID) async {
    bool isJoined = false;
    final String currentUserID = getCurrentUserID();

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("following")
        .doc(userID);

    var data = await bandMemRef.get();

    if (data.exists) {
      isJoined = true;
    }

    return isJoined;
  }

  static Future<bool> followUser(String? userID) async {
    final String currentUserID = getCurrentUserID();

    final DocumentReference userFollowerRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("followers")
        .doc(currentUserID);

    final DocumentReference userFollowerCountRef =
        FirebaseFirestore.instance.collection("users").doc(userID);

    final DocumentReference userFollowingCountRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);

    final DocumentReference userFollowingRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("following")
        .doc(userID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(
          userFollowerCountRef, {'followerCount': FieldValue.increment(1)});
      batch.update(
          userFollowingCountRef, {'followingCount': FieldValue.increment(1)});
      batch.set(userFollowerRef, {'userId': currentUserID});
      batch.set(userFollowingRef, {'userId': userID});

      await batch.commit();
      FirebaseDBOperations.subscribeToTopic(userID ?? "");
      return true;
    } catch (error) {
      print("Error joining band: $error");
      return false;
    }
  }

  static Future<bool> unfollowUser(String? userID) async {
    final String currentUserID = getCurrentUserID();

    final DocumentReference userFollowerCountRef =
        FirebaseFirestore.instance.collection("users").doc(userID);

    final DocumentReference userFollowingCountRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);

    final DocumentReference bandMemRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("followers")
        .doc(currentUserID);

    final DocumentReference userBandRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("following")
        .doc(userID);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(
          userFollowerCountRef, {'followerCount': FieldValue.increment(-1)});
      batch.update(
          userFollowingCountRef, {'followingCount': FieldValue.increment(-1)});
      batch.delete(bandMemRef);
      batch.delete(userBandRef);

      await batch.commit();
      FirebaseDBOperations.unsubscribeFromTopic(userID ?? "");
      return true;
    } catch (error) {
      print("Error leaving band: $error");
      return false;
    }
  }

  static Future<List<Drummer>> getPeople(String query) async {
    print("getPeople triggered");
    // List<Drummer> emptyList = [];
    // if (query.length >= 3) {
    //   final uid = FirebaseAuth.instance.currentUser?.uid;
    //   var data = await FirebaseFirestore.instance
    //       .collection('users')
    //       .where('name', isGreaterThanOrEqualTo: query)
    //       .where('name', isLessThan: query + '\uf8ff')
    //       // .doc(uid)
    //       // .collection('questions')
    //       //.orderBy('createdTime',descending: true)
    //       .get();
    //   return List.from(data.docs.map((e) => Drummer.fromSnapshot(e)));
    // } else
    //   return emptyList;

    AlgoliaQuerySnapshot getArticles =
        await algolia.instance.index('users').query(query).getObjects();

    //print("Getting Articles from Algolia ${getArticles.hits.elementAt(0).data["title"]}");
    List<Drummer> result = List.from(
        getArticles.hits.map((e) => Drummer.fromAlgoliaSnapshot(e.data)));

    return result;
  }

  static Future<Drummer> getDrummer(String uid) async {
    Drummer drummer = Drummer();
    // print("getQuestionsAsked triggered");
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .onError((error, stackTrace) {
      var data;
      DocumentSnapshot<Map<String, dynamic>> snapshot = data;
      return snapshot;
    });
    if (data.exists) drummer = Drummer.fromSnapshot(data);

    return drummer;
  }

  static Future<Article> getArticle(String articleId) async {
    Article article = Article();
    print("getArticle triggered");
    var data = await FirebaseFirestore.instance
        .collection('articles')
        .doc(articleId)
        .get();
    article = Article.fromJson(data);
    print("${data.data()}");

    return article;
  }

  /// Notification functions start
  static void subscribeToTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
    await messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  static void subscribeToUserBands() async {
    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    FirebaseDBOperations.subscribeToTopic("broadcast");
    for (Band band in fetchedBands) {
      FirebaseDBOperations.subscribeToTopic(band.bandId ?? "");
    }
  }

  static void unSubscribeToUserBands() async {
    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    for (Band band in fetchedBands) {
      FirebaseDBOperations.unsubscribeFromTopic(band.bandId ?? "");
    }
  }

  static void unsubscribeFromTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  static Future<void> sendRingingNotification(
      String deviceToken, Jam jam) async {
    var url = Uri.https('fcm.googleapis.com', '/fcm/send');
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAA8pEyjik:APA91bFjoRwCsioHAgDsWYHhcmy63BQuxL3iUBBaYnE9s2SHMnJtl0oyD39Mdp0KphI53ldusblYoiCCvxNaKJEFVQbGVTrwMcqDu9w_Rpx_Vsjx_9TdE3xI54vqj0lNOPDqAb5GPwOp'
    };
    final body = jsonEncode({
      "to": deviceToken,
      "notification": {
        "body": jam.title,
        "title": "Drumm Call",
        "sound": "conga_drumm.caf",
        "subtitle": "You asked"
      },
      "priority": "high",
      "content_available": true,
      "mutable_content": true,
      "data": {
        "bandId": jam.bandId,
        "jamId": jam.jamId,
      }
    });

    var response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 200) {
      /*
     Map<String, dynamic> json = jsonDecode(response.body);
     List<dynamic> list = json['choices'];
     String searchResult = list[0]["text”];
     */
    } else {
      throw Exception('Failed to send calling notification');
    }
  }

  static Future<void> sendNotificationToDeviceToken(Jam jam) async {
    print("Sending notification");
    var url = Uri.https('fcm.googleapis.com', '/fcm/send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
    String deviceToken = drummer.token ?? "";
    print("Device Token is: ${deviceToken}");

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAA8pEyjik:APA91bFjoRwCsioHAgDsWYHhcmy63BQuxL3iUBBaYnE9s2SHMnJtl0oyD39Mdp0KphI53ldusblYoiCCvxNaKJEFVQbGVTrwMcqDu9w_Rpx_Vsjx_9TdE3xI54vqj0lNOPDqAb5GPwOp'
    };

    String subtitle = "Hey ${drummer.username}! Did you know?";
    //Due to conversion error, setting the timestamo for lastActive as null
    jam.lastActive = null;
    final body = jsonEncode({
      "to": deviceToken,
      "notification": {
        "body": (jam.question != null)
            ? "${jam.title}\n\n${jam.question}"
            : "${jam.title}",
        "title": subtitle,
        "sound": "conga_drumm.caf",
        "image": "${jam.imageUrl}"
      },
      "priority": "high",
      "content_available": true,
      "mutable_content": true,
      "data": {"jam": jam, "ring": false, "drummerID": uid, "open": true}
    });
    var response = await http.post(url, headers: header, body: body);

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      print("Sent Notification to device Token");
      Map<String, dynamic> json = jsonDecode(response.body);
      /*List<dynamic> list = json['choices'];
    String searchResult = list[0]["text”];*/
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      print("Failed to send deviceToken notification ${response.statusCode}");
      throw Exception(
          'Failed to send deviceToken notification ${response.statusCode}');
    }
  }

  static Future<void> sendNotificationToTopic(
      Jam jam, bool ring, bool open) async {
    print("Sending notification");
    var url = Uri.https('fcm.googleapis.com', '/fcm/send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
    bool isBroadcast = jam.broadcast ?? false;
    var toParams = "";
    if (isBroadcast) {
      toParams = "/topics/" + 'creator';
    } else {
      toParams = "/topics/" + '${jam.bandId}';
    }

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAA8pEyjik:APA91bFjoRwCsioHAgDsWYHhcmy63BQuxL3iUBBaYnE9s2SHMnJtl0oyD39Mdp0KphI53ldusblYoiCCvxNaKJEFVQbGVTrwMcqDu9w_Rpx_Vsjx_9TdE3xI54vqj0lNOPDqAb5GPwOp'
    };

    String type = "notification";
    String subtitle = (ring)
        ? "${drummer.username} is drumming..."
        : (isBroadcast)
            ? "Welcome ${drummer.username} to Drumm"
            : "${drummer.username} is drumming...";
    if (ring) type = "data";

    var notifcationBody =
        (jam.question != null) ? "${jam.question}\n\n${jam.title}" : jam.title;
    //Due to conversion error, setting the timestamo for lastActive as null
    jam.lastActive = null;
    final body = jsonEncode({
      "to": "${toParams}",
      //if (!ring)
      "notification": {
        "body": notifcationBody,
        "title": subtitle,
        "sound": "conga_drumm.caf",
        "image": "${jam.imageUrl}"
      },
      "priority": "high",
      "content_available": true,
      "mutable_content": true,
      "data": {"jam": jam, "ring": ring, "drummerID": uid, "open": true}
    });
    var response = await http.post(url, headers: header, body: body);

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      print("Sent Notification to Topic");
      Map<String, dynamic> json = jsonDecode(response.body);
      /*List<dynamic> list = json['choices'];
    String searchResult = list[0]["text”];*/
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      print("Failed to send topic notification ${response.statusCode}");
      throw Exception(
          'Failed to send topic notification ${response.statusCode}');
    }
  }

  // Notification functions end

  static Future<Band> getBand(String bandId) async {
    Band band = Band();
    print("getBand triggered");
    var data =
        await FirebaseFirestore.instance.collection('bands').doc(bandId).get();
    band = Band.fromSnapshot(data);
    print("${data.data()}");

    return band;
  }

  static Future<List<Article>> getArticles(String query) async {
    print("getArticles triggered");
    List<Article> emptyList = [];
    //searchArticles(query);
    if (query.length >= 3) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      var data = await FirebaseFirestore.instance
          .collection('articles')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          // .doc(uid)
          // .collection('questions')
          //.orderBy('createdTime',descending: true)
          .get();
      print(data.docs.length);
      return List.from(data.docs.map((e) => Article.fromJson(e)));
    } else {
      return emptyList;
    }
  }

  static Future<List<Article>> getArticlesByUser(String uid) async {
    print("getArticles triggered");
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection('articles')
        .where('uid', isEqualTo: uid)
        // .doc(uid)
        // .collection('questions')
        //.orderBy('createdTime',descending: true)
        .get();
    print(data.docs.length);
    return List.from(data.docs.map((e) => Article.fromJson(e)));
  }

  static Future<List<Drummer>> getUsersByBand(Band band) async {
    // Assuming you have already initialized the Firestore instance and have a reference to the "bands" collection
    String userID = FirebaseAuth.instance.currentUser!.uid;
    print(userID);
    CollectionReference userbandsCollectionRef = FirebaseFirestore.instance
        .collection("bands")
        .doc(band.bandId)
        .collection("members");
    var bandsData = await userbandsCollectionRef.limit(5).get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)!["userId"].toString();
    }));
    print(list.toString());

    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("users");

    // Define the userID you want to search for

    // Construct the query
    print("getUsersByBand triggered");
    var data = await bandsCollectionRef.where("uid", whereIn: list).get();
    print(data.docs.toString());

    // Execute the query
    return List.from(data.docs.map((e) => Drummer.fromSnapshot(e)));
  }

  static Future<List<String>> getBandHooks() async {
    var data = await FirebaseFirestore.instance
        .collection("hooks")
        .doc("tags")
        .get()
        .onError((error, stackTrace) {
      var data;
      DocumentSnapshot<Map<String, dynamic>> snapshot = data;
      return snapshot;
    });
    List<dynamic> bandHooks = [];
    if (data.exists) {
      bandHooks = data.data()!['hooks'];
    }

    return List<String>.from(bandHooks);
  }

  static Future<List<Band>> getBandByUser() async {
    // Assuming you have already initialized the Firestore instance and have a reference to the "bands" collection
    String userID = FirebaseAuth.instance.currentUser!.uid;
    print(userID);
    CollectionReference userbandsCollectionRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("mybands");
    var bandsData = await userbandsCollectionRef.get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)!["bandId"].toString();
    }));
    print("The user bands are ${list.toString()}");

    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("bands");

    // Define the userID you want to search for

    // Construct the query
    print("getBandByUser triggered");
    if (list.isEmpty) {
      print("bandsData list is null");
      return [];
    }
    try {
      var data = await bandsCollectionRef.where("bandId", whereIn: list).get();
      print("Band fetched result ${data}");
      print(data.docs.toString());

      // Execute the query
      return List.from(data.docs.map((e) => Band.fromSnapshot(e)));
    } catch (e) {
      print("Unable to fetch bands because ${e.toString()}");
      return [];
    }
  }

  static Future<List<Article>> getArticlesByBandID(
      List<dynamic> bandHook) async {
    List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandHook)
        // .where('articleId', whereNotIn: seenPosts)
        .where('country', isEqualTo: 'in')
        .where('publishedAt', isNotEqualTo: null)
        .orderBy("publishedAt", descending: true)
        .limit(50);

    List<Article> filterArticle = [];
    bool checkedEverything = false;
    while (filterArticle.isEmpty && !checkedEverything) {
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) lastDocument = snapshot.docs.last;

      List<Article> newArticles =
          snapshot.docs.map((doc) => Article.fromJson(doc)).toList();

      if (newArticles.isEmpty) checkedEverything = true;

      for (Article article in newArticles) {
        if (!seenPosts.contains(article.articleId) || checkedEverything) {
          filterArticle.add(article);
        }
      }
    }

    ///Uncomment the below code if you want to replay the articles after you have seen everything
    // if(filterArticle.length<1&&checkedEverything){
    //   Query<Map<String, dynamic>> query = FirebaseFirestore.instance
    //       .collection('articles')
    //       .where('category', isEqualTo: bandID)
    //   // .where('country', isEqualTo: 'in')
    //       .where('source', isNotEqualTo: null)
    //       .orderBy("publishedAt", descending: true)
    //       .limit(50);
    //   final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    //   filterArticle = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
    // }

    return filterArticle;
  }

  static Future<List<Band>> getOnboardingBands() async {
    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("bands");

    // Define the userID you want to search for

    // Construct the query
    print("getOnboardingBands triggered");
    List<String> bandIDs = [
      "sports",
      "entertainment",
      "politics",
      "science",
      "health",
      "business",
      "technology"
    ];

    var data = await bandsCollectionRef.where("bandId", whereIn: bandIDs).get();
    print(data.docs.toString());

    // Execute the query
    return List.from(data.docs.map((e) => Band.fromSnapshot(e)));
  }

  // static void getRealtimeJamData(String jamId, JamCallback jamCallback) {
  //   realtime.DatabaseReference starCountRef =
  //       realtime.FirebaseDatabase.instance.ref('jams/${jamId}');
  //   starCountRef.onValue.listen((realtime.DatabaseEvent event) {
  //     Jam data = Jam.fromRealtimeSnapshot(event.snapshot);
  //     jamCallback(data);
  //   });
  // }

  static Future<Jam> getJamData(String jamId, bool open) async {
    String path = "";
    if (open) {
      path = "openDrumm";
    } else {
      path = "openDrumm";
    }

    CollectionReference jamCollection =
        FirebaseFirestore.instance.collection(path);

    DocumentSnapshot doc =
        await jamCollection.doc("$jamId").get().catchError((onError) {
      var data;
      return data;
    });

    try {
      return Jam.fromDocListenSnapshot(doc);
    } catch (error) {
      return Jam();
    }
    // listener = jamCollection.doc("$jamId").snapshots().listen((event) {
    //   print("Event!!!!!!!!! $event");
    //   jamCallback(Jam.fromDocListenSnapshot(event));
    // });
  }

  static void stopListening() {
    listener.cancel();
  }

  static void createJamData(Jam jam) {
    CollectionReference jamCollection =
        FirebaseFirestore.instance.collection('openDrumm');
    jamCollection.doc(jam.jamId ?? "").set(jam.toJson()).then((_) {
      print('Jam data stored successfully in Realtime Database and Firestore.');
    }).catchError((error) {
      print('Error storing Jam data in Firestore: $error');
    });
  }

  static void createOpenDrumm(Jam jam) {
    CollectionReference jamCollection =
        FirebaseFirestore.instance.collection('openDrumm');
    jamCollection
        .doc(jam.jamId ?? "")
        .set(jam.toJson(), SetOptions(merge: true))
        .then((_) {
      print('Jam data stored successfully in Realtime Database and Firestore.');
    }).catchError((error) {
      print('Error storing open data in Firestore: $error');
    });
  }

  static void updateDrummerSpeaking(bool talking) {
    DocumentReference drummerSpeaking =
        FirebaseFirestore.instance.collection('users').doc(getCurrentUserID());

    drummerSpeaking.update({"speaking": talking});
  }

  static void updateDrummerToken(String token) {
    try {
      DocumentReference drummerSpeaking = FirebaseFirestore.instance
          .collection('users')
          .doc(getCurrentUserID());

      drummerSpeaking.update({"token": token});
    } catch (e) {
      print("Unable to update device token${e}");
    }
  }

  static void addMemberToRoom(String jamId, String memberId) async {
    DocumentReference memberRef =
        FirebaseFirestore.instance.collection("openDrumm").doc(jamId);

    final sfDocRef =
        FirebaseFirestore.instance.collection("openDrumm").doc(jamId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(memberRef);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      Jam jam = Jam.fromDocListenSnapshot(snapshot);
      final count = snapshot.get("count") + 1;
      List<dynamic> memList = jam.membersID ?? [];
      if (!memList.contains(FirebaseAuth.instance.currentUser?.uid ?? "")) {
        memList.add(FirebaseAuth.instance.currentUser?.uid ?? "");
      }
      transaction.update(sfDocRef,
          {"count": count, "membersID": memList}); //,"membersID":memList
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"),
    );
  }

  static Future<bool> addMemberToJam(
      String jamId, String memberId, bool open) async {
    print("adding Member from Jam $jamId");
    bool result = false;
    try {
      String path = "";
      if (open) {
        path = "openDrumm";
      } else {
        path = "openDrumm";
      }
      DocumentReference memberRef =
          FirebaseFirestore.instance.collection(path).doc(jamId);

      result = await memberRef.update({
        "membersID": FieldValue.arrayUnion([memberId])
      }).then((value) {
        return true;
      }).catchError((onError) {
        print('Error while adding member: $onError');
        return false;
      });
    } catch (e) {
      return result = false;
    }

    return result;

    // final sfDocRef = FirebaseFirestore.instance.collection("openDrumm").doc(jamId);
    // FirebaseFirestore.instance.runTransaction((transaction) async {
    //   final snapshot = await transaction.get(memberRef);
    //   // Note: this could be done without a transaction
    //   //       by updating the population using FieldValue.increment()
    //   Jam jam = Jam.fromDocListenSnapshot(snapshot);
    //   final count = snapshot.get("count") + 1;
    //   List<dynamic> memList = jam.membersID ?? [];
    //   if (!memList.contains(FirebaseAuth.instance.currentUser?.uid ?? ""))
    //     memList.add(FirebaseAuth.instance.currentUser?.uid ?? "");
    //   transaction.update(sfDocRef,
    //       {"count": count, "membersID": memList}); //,"membersID":memList
    // }).then(
    //       (value) => print("DocumentSnapshot successfully updated!"),
    //   onError: (e) => print("Error updating document $e"),
    // );
  }

  static void removeMemberFromJam(
      String jamId, String memberId, bool open) async {
    try {
      print("removing Member from Jam $jamId");
      String path = "";

      if (open) {
        path = "openDrumm";
      } else {
        path = "openDrumm";
      }
      try {
        DocumentReference memberRef =
            FirebaseFirestore.instance.collection(path).doc(jamId);

        memberRef
            .update({
              "membersID": FieldValue.arrayRemove([memberId])
            })
            .onError((error, stackTrace) => null)
            .then((value) => print("Member removed successfully"));
      } catch (err) {
        print("jamId ${jamId}");
        print("Error while removing member ${err}");
      }
    } catch (e) {}
  }

  static void removeMemberFromRoom(String jamId, String memberId) async {
    DocumentReference memberRef =
        FirebaseFirestore.instance.collection("openDrumm").doc(jamId);

    final sfDocRef =
        FirebaseFirestore.instance.collection("openDrumm").doc(jamId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(memberRef);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      Jam jam = Jam.fromDocListenSnapshot(snapshot);
      final count = snapshot.get("count") - 1;
      List<dynamic> memList = jam.membersID ?? [];
      if (memList.contains(FirebaseAuth.instance.currentUser?.uid ?? "")) {
        memList.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
      }
      transaction.update(sfDocRef,
          {"count": count, "membersID": memList}); //,"membersID":memList
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"),
    );
  }
}
