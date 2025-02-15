import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:algolia/algolia.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/helper/access_firebase_token.dart';
import 'package:drumm_app/model/Stats.dart';
import 'package:drumm_app/model/profession.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as realtime;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/question.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/animation.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:http/http.dart' as http;

import '../../model/AiVoice.dart';
import '../../model/algolia_article.dart';
import '../../model/band.dart';

typedef void UpdateCallback();

typedef void JamCallback(Jam jam);

class FirebaseDBOperations {
  static var listener;
  static late AnimationController ANIMATION_CONTROLLER;

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
        .index("stories")
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
        .index("stories")
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
    //   //print("You have seen all articles");
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
        .collection("stories")
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'us')
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
      //print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }

  static Future<List<Article>> getClusteredArticles(String clusterId, Article article) async{

    List<Article> clusteredArticles = [];
    print('The cluster Id is: ${clusterId}');

    DocumentSnapshot<Map<String, dynamic>> articleSnapshot = await FirebaseFirestore.instance
        .collection('stories')
        .doc(article.articleId)
        .get();

    Article updatedArticle =  Article.fromJson(articleSnapshot);


    query = FirebaseFirestore.instance
        .collection("stories")
        .where('clusterId', isEqualTo: updatedArticle.clusterId)
        .where('isRepresentative',isEqualTo: false)
        .orderBy("publishedAt", descending: true);


    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      clusteredArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
    } else {
      print('Nothing found');
    }

    return clusteredArticles;
  }

  static Future<List<Article>> getSimilarArticlesBySimilarId(String similarId, Article article) async{

    List<Article> similarArticles = [];

    DocumentSnapshot<Map<String, dynamic>> articleSnapshot = await FirebaseFirestore.instance
        .collection('stories')
        .doc(article.articleId)
        .get();

    Article updatedArticle =  Article.fromJson(articleSnapshot);

    query = FirebaseFirestore.instance
        .collection("stories")
        .where('similarId', isEqualTo: updatedArticle.similarId)
        .orderBy("publishedAt", descending: true)
        .limit(5);


    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      similarArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
    } else {
      //print('Nothing found');
    }

    // Remove the passed article from the list
    similarArticles.removeWhere((similarArticle) => similarArticle.articleId == article.articleId);


    return similarArticles;
  }

  static bool isTimestampWithinThreeHours(Timestamp? firebaseTimestamp) {
    // Use a default older date if firebaseTimestamp is null
    firebaseTimestamp ??= Timestamp.fromDate(DateTime(2000));

    // Get the current timestamp
    final currentTimestamp = Timestamp.now();

    // Compute the difference in milliseconds
    final differenceMilliseconds = currentTimestamp.millisecondsSinceEpoch -
        firebaseTimestamp.millisecondsSinceEpoch;

    // Compare against a 3-hour Duration
    final threeHoursInMs = const Duration(hours: 1).inMilliseconds;

    return differenceMilliseconds < threeHoursInMs;
  }




  static Future<AlgoliaArticles> getUserRecommendedArticles(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;
    Drummer drummer = Drummer();
    // if(CURRENT_DRUMMER.uid!=null)
    //   drummer = CURRENT_DRUMMER;
    // else
      drummer = await getDrummer(getCurrentUserID());
    if(drummer.preference!=null){
      //print("preference is not null");
      if (!isTimestampWithinThreeHours(drummer.lastRecommendationTimestamp ?? Timestamp.fromDate(DateTime(2000)))) {

        print("User recommendations are outdated, so calling the vector search.");
        // Your code here
        Timestamp recommendTimestamp = drummer.lastRecommendationTimestamp ?? Timestamp.fromDate(DateTime(2000));
        generateRecommendation(recommendTimestamp);
        List<Article> vectorSearchArticles = await performVectorSearch(drummer.preference,recommendTimestamp);

        AlgoliaArticles algoliaArticles = AlgoliaArticles(
            articles: vectorSearchArticles, queryID: fetchedLastDocument.toString());

        algoliaArticles.setLastDocument(fetchedLastDocument);
        algoliaArticles.setStartDocument(fetchedStartDocument);

        //print("returned vector search result");

        return algoliaArticles;
      }else{
        //print("User recommendations are fresh, so taking directly from the recommendations collections.");
      }
    }else{
      //print("preference is null");
      if (_lastDocument == null)
        generateRecommendation(Timestamp.fromDate(DateTime(2000)));
      return await getArticlesData(_startDocument,_lastDocument,reverse);
    }
    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();
    List bandCategoryList = [];

    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks ?? []);
    }
    if (fetchedBands.isEmpty) bandCategoryList.add("general");
    query = FirebaseFirestore.instance
        .collection("recommendations")
        .doc(getCurrentUserID())
        .collection("articles")
        .where('category', whereIn: bandCategoryList)
        .orderBy("recommendedTimestamp", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      try {
        query = query.startAfterDocument(_lastDocument!);
      }catch(e){
        //_lastDocument = null;
        //query = query.startAfterDocument(_lastDocument!);
      }
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found in recommendations');
      AlgoliaArticles algoliaArticles = await  getArticlesData(_startDocument, _lastDocument, reverse);

      algoliaArticles.setLastDocument(fetchedLastDocument);
      algoliaArticles.setStartDocument(fetchedStartDocument);

      return algoliaArticles;
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }
  static Future<AlgoliaArticles> checkForFreshRecommendedArticles(
      DocumentSnapshot<Map<String, dynamic>>? _startDocument,
      DocumentSnapshot<Map<String, dynamic>>? _lastDocument,
      bool reverse) async {
    DocumentSnapshot<Map<String, dynamic>>? fetchedStartDocument = null;
    DocumentSnapshot<Map<String, dynamic>>? fetchedLastDocument = null;
    fetchedBands = await FirebaseDBOperations.getBandByUser();
    List bandCategoryList = [];

    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks ?? []);
    }
    if (fetchedBands.isEmpty) bandCategoryList.add("general");
    query = FirebaseFirestore.instance
        .collection("recommendations")
        .doc(getCurrentUserID())
        .collection("articles")
        .where('category', whereIn: bandCategoryList)
        .orderBy("recommendedTimestamp", descending: true)
        .limit(10);

    if (_lastDocument != null) {
      try {
        query = query.startAfterDocument(_lastDocument!);
      }catch(e){
        _lastDocument = null;
        //query = query.startAfterDocument(_lastDocument!);
      }
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    List<Article> newArticles = [];
    if (snapshot.docs.isNotEmpty) {
      newArticles = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      fetchedLastDocument =
          snapshot.docs.last; // Save the last document for the next page
      fetchedStartDocument = snapshot.docs.first;
    } else {
      print('Nothing found in recommendations');
      AlgoliaArticles algoliaArticles = await  getArticlesData(_startDocument, _lastDocument, reverse);

      algoliaArticles.setLastDocument(fetchedLastDocument);
      algoliaArticles.setStartDocument(fetchedStartDocument);

      return algoliaArticles;
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

    return algoliaArticles;
  }
  static void generateRecommendation(Timestamp recommendTimestamp) async {
    try {
      // Create a callable reference to the vectorSearch Cloud Function

    print("Calling generateRecommendation function");

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('generateRecommendations');

      String? userId = FirebaseAuth.instance.currentUser?.uid;



      // Call the Cloud Function with userId and limit
      final result = await callable.call({
        'userId': userId??"",
        'recommendTimestamp':recommendTimestamp.millisecondsSinceEpoch.toString()??"",
      });

      //print("Finished generating recommendation with the result${result.data['message']}");
    } catch (error) {
      //print('Error performing vector search: $error');
      //return [];
    }
  }
  static Future<List<Article>> performVectorSearch(VectorValue? preference, Timestamp recommendTimestamp) async {
    try {
      // Create a callable reference to the vectorSearch Cloud Function

      print("Perform vector search");

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('vectorSearch');

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      //print('The user Id is : $userId');

      // Call the Cloud Function with userId and limit
      final result = await callable.call({
        'userId': userId??"",
        'limit': 25,
        'preference' :preference?.toArray(),
        'recommendTimestamp':recommendTimestamp.millisecondsSinceEpoch.toString()
      });

      ////print('Raw response from Cloud Function: ${result.data['articles'][0]}');


      // Parse the response
      List<Article> articles = (result.data['articles'] as List<dynamic>)
          .map((articleData) => Article.fromCloudFunction(articleData))
          .toList();

      if(articles.isEmpty){
        //
        print('No Articles fetched from vector search. Checking for existing recommended data');
        AlgoliaArticles algoliaArticles = await FirebaseDBOperations.checkForFreshRecommendedArticles(null,null,false);
        List<Article>? fetchedArticles = algoliaArticles.articles;
        int fetchedArticlesSize = fetchedArticles?.length??0;
        if(fetchedArticlesSize==0){
          AlgoliaArticles algoliaArticles = await FirebaseDBOperations.getArticlesData(null,null,false);
          List<Article>? fetchedArticles = algoliaArticles.articles;
          articles = fetchedArticles??[];
        }else{
          articles = fetchedArticles??[];
        }
      }

      return articles;
    } catch (error) {
      print('Error performing vector search: $error');
      return [];
    }
  }

  static Future<List<Article>> performSemanticSearch(VectorValue? embedding, Article article) async {
    try {
      // Create a callable reference to the vectorSearch Cloud Function

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('semanticSearch');

      //print('The user Id is : $userId');

      // Call the Cloud Function with userId and limit
      final result = await callable.call({
        'limit': 5,
        'embedding' :embedding?.toArray()
      });

      ////print('Raw response from Cloud Function: ${result.data['articles'][0]}');


      // Parse the response
      final List<Article> articles = (result.data['articles'] as List<dynamic>)
          .map((articleData) => Article.fromCloudFunction(articleData))
          .toList();

      articles.removeWhere((similarArticle) => similarArticle.articleId == article.articleId);

      return articles;
    } catch (error) {
      //print('Error performing vector search: $error');
      return [];
    }
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
        .collection("stories")
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'us')
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
      //print('Nothing found');
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
        .collection("stories")
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'us')
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
      //print('Nothing found');
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
        .collection("stories")
        .where('category', whereIn: bandCategoryList)
        .where('country', isEqualTo: 'us')
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
      //print('Nothing found');
    }

    AlgoliaArticles algoliaArticles = AlgoliaArticles(
        articles: newArticles, queryID: fetchedLastDocument.toString());

    algoliaArticles.setLastDocument(fetchedLastDocument);
    algoliaArticles.setStartDocument(fetchedStartDocument);

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
        .index("stories")
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

  static void updateArticle(
      String articleID, Article updatedArticle, UpdateCallback callback) {
    FirebaseFirestore.instance
        .collection("stories")
        .doc(articleID)
        .set(
          updatedArticle.toJson(),
        )
        .then((_) {
      //print('Article updated successfully!');
      callback(); // Invoke the callback when the update completes
    }).catchError((error) {
      //print('Failed to update article: $error');
    });
  }

  static Future<bool> updateLike(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
        FirebaseFirestore.instance.collection("stories").doc(articleID);
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
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, {'liked': true, 'timestamp':Timestamp.fromDate(currentTime)});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateListened(String? articleID, VectorValue? embedding) async {
    final String currentUserID = getCurrentUserID();
    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, {'timestamp':Timestamp.fromDate(currentTime), 'articleId':articleID,'type':'listened','userId':currentUserID,'interactionId':newInteractionId,'weight':WEIGHT_LISTENED,'embedding':embedding});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating listened status: $error");
      return false;
    }
  }

  static Future<bool> updateShared(String? articleID, VectorValue? embedding) async {
    final String currentUserID = getCurrentUserID();
    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, {'timestamp':Timestamp.fromDate(currentTime), 'articleId':articleID,'type':'shared','userId':currentUserID,'interactionId':newInteractionId,'weight':WEIGHT_SHARED,'embedding':embedding});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating shared status: $error");
      return false;
    }
  }

  static Future<bool> updateRead(String? articleID, VectorValue? embedding) async {
    final String currentUserID = getCurrentUserID();
    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, {'timestamp':Timestamp.fromDate(currentTime),
        'articleId':articleID,
        'type':'read',
        'userId':currentUserID,
        'embedding':embedding,
        'interactionId':newInteractionId,'weight':WEIGHT_READ});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating read status: $error");
      return false;
    }
  }

  static Future<bool> updateBoosts(String? articleID, VectorValue? embedding) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
    FirebaseFirestore.instance.collection("stories").doc(articleID);

    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;

    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);


    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(articleRef, {
        'boosts': FieldValue.increment(1),
        'boostamp': Timestamp.now()
      });
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, { 'timestamp':Timestamp.fromDate(currentTime), 'articleId':articleID,'type':'boosted','userId':currentUserID, 'interactionId':newInteractionId,'weight':WEIGHT_BOOSTED,'embedding':embedding});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating like status: $error");
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
        .collection("stories")
        .doc(articleID)
        .update({'summary': summary ?? ""});
  }

  static void updateReads(String? articleID) async {
    //final DocumentReference articleRef =
    FirebaseFirestore.instance
        .collection("stories")
        .doc(articleID)
        .update({'reads': FieldValue.increment(1)});
  }

  static Future<bool> removeLike(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
        FirebaseFirestore.instance.collection("stories").doc(articleID);
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
      //print("Error removing like status: $error");
      return false;
    }
  }

  static Future<bool> removeBoost(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    final DocumentReference articleRef =
    FirebaseFirestore.instance.collection("stories").doc(articleID);

    final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection("userActivity")
        .doc(getCurrentUserID())
        .collection("interactions")
        .where('type', isEqualTo: 'boosted')
        .where('articleId', isEqualTo: articleID).get();

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      DateTime currentTime = DateTime.now();
      DateTime oneDayAgo = currentTime.subtract(Duration(days: 1));


      batch.update(articleRef, {
        'likes': FieldValue.increment(-1),
        'boosts': FieldValue.increment(-1),
        'boostamp':Timestamp.fromDate(oneDayAgo),
      });

      for (var doc in data.docs) {
        var docRef = FirebaseFirestore.instance
            .collection("userActivity")
            .doc(getCurrentUserID())
            .collection("interactions")
            .doc(doc.id);

        batch.delete(docRef);
      }

      await batch.commit();
      //print("Removed Boost");
      return true;
    } catch (error) {
      //print("Error removing like status: $error");
      return false;
    }
  }

  static String getCurrentUserID() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userID = user?.uid ?? '';
    //  //print("CurrentUserID is $userID");
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
      //print("Error checking like status: $error");
      return false;
    }
  }

  static Future<bool> hasBoosted(String? articleID) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
          .collection("userActivity")
          .doc(getCurrentUserID())
          .collection("interactions")
          .where('type', isEqualTo: 'boosted')
          .where('articleId', isEqualTo: articleID)
          .get();
      return data.docs.isNotEmpty;

      //return doc.exists;
    } catch (error) {
      //print("Error checking like status: $error");
      return false;
    }
  }

  static Future<bool> updateSeen(String? articleID) async {
    final String currentUserID = getCurrentUserID();
    // final DocumentReference articleRef =
    // FirebaseFirestore.instance.collection("stories").doc(articleID);
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
      //print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateJoined(String? articleID, VectorValue? embedding) async {
    final String currentUserID = getCurrentUserID();
    // final DocumentReference articleRef =
    // FirebaseFirestore.instance.collection("stories").doc(articleID);
    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      // batch.update(articleRef, {'likes': FieldValue.increment(1)});
      DateTime currentTime = DateTime.now();
      batch.set(userLikeRef, {'joined': true, 'timestamp':Timestamp.fromDate(currentTime),'type':'joined','userId':currentUserID,'articleId':articleID,'interactionId':newInteractionId, 'weight':WEIGHT_JOINED,'embedding':embedding});

      await batch.commit();
      return true;
    } catch (error) {
      //print("Error updating joined status: $error");
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
      //print("Error fetching seen list: $error");
      return [];
    }
  }

  static Future<List<Question>> getMyQuestions() async {
    //print("getQuestionsAsked triggered");
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
      Question notifQuestion = question;

      // Post the question to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('questions')
          .doc(question.qid)
          .set(question.toFirestoreJson())
          .onError(
              (error, stackTrace) => //print('Error posting question: $error'));

      //print(
          'Question posted successfully Users/$uid/questions/${question.qid} \n ${question.toJson()}');
      sendQuestionNotificationToTopic(notifQuestion);
    } catch (error) {
      //print('Error posting question: $error');
      // Handle error as needed
    }
  }



  static Future<List<Question>> getQuestionsAsked() async {
    try {
      //print("getQuestionsAsked triggered");
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //List<String> userInterests = prefs.getStringList('interestList')!;

      Drummer currentDrummer = await getDrummer(
          FirebaseAuth.instance.currentUser?.uid ?? "");

      String designation = currentDrummer.jobTitle ?? "";
      String departmentName = currentDrummer.occupation ?? "";

      DateTime currentTime = DateTime.now();

      // Calculate the time one minute ago
      DateTime oneDayAgo = currentTime.subtract(Duration(days: 1));

      var data = await FirebaseFirestore.instance
          .collectionGroup('questions')
          .where('createdTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
          .where('departmentName', isEqualTo: departmentName ?? "")
      //.where('designation',isEqualTo: designation??"")
          .orderBy('createdTime', descending: true)
      //.where("hook", whereIn: userInterests)
          .get();

      // List<Question> listOfQuestionsFetched = List.from(data.docs.map((e) => Question.fromSnapshot(e)));
      // List<Question> finalList = [];
      // for(Question question in listOfQuestionsFetched){
      //   String designationQ = question.designation??"";
      //   if(designationQ.isEmpty || designationQ == designation){
      //     finalList.add(question);
      //   }
      // }
      return List.from(
          data.docs.map((e) => Question.fromSnapshot(e))); //finalList;
    }catch(e){
      return [];
    }
  }

  static Future<List<String>> getGeneratedAMAQuestions() async {
    try {
      // Access the Firestore collection and document
      DocumentSnapshot<Map<String, dynamic>>? docSnapshot = await FirebaseFirestore.instance
          .collection('generated_questions')
          .doc('questions')
          .get();

      // Check if the document exists and contains the 'questions' field
      if (docSnapshot?.exists ?? false && docSnapshot?.data() != null) {
        List<String> questions =
        List<String>.from(docSnapshot!.data()!['questions'] ?? []);
        return questions;
      } else {
        return []; // Return an empty list if the document doesn't exist or doesn't contain the 'questions' field
      }
    } catch (error) {
      //print('Error retrieving questions: $error');
      return []; // Return an empty list if an error occurs
    }
  }

  static Future<List<Question>> getQuestionsAskedByUserId(String uid) async {
    //print("getQuestionsAsked triggered");
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //List<String> userInterests = prefs.getStringList('interestList')!;

    DateTime currentTime = DateTime.now();

    // Calculate the time one minute ago
    DateTime oneDayAgo = currentTime.subtract(Duration(days: 1));

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
        .where('createdTime', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
    .limit(100)
    //.where("hook", whereIn: userInterests)
        .get();

    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static void deletedQuestionsAskedByQuestionId(String uid, String qid) async {
    //print("deletedQuestionsAskedByQuestionId triggered");
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
    .doc(qid).delete();

  }

  static Future<void> incrementCategoryPoints(String category, int increment) async {
    // Reference to the Firestore collection where user data is stored
    var usersCollection = FirebaseFirestore.instance.collection('stats');

    // Get the user document by user ID
    var userDoc = usersCollection.doc(getCurrentUserID());

    try {
      // Run a transaction to ensure atomic increment
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the snapshot of the user's document
        var snapshot = await transaction.get(userDoc);

        // Check if the document exists
        if (!snapshot.exists) {
          // If the document does not exist, create it with the initial point value for the category
          transaction.set(userDoc, {
            category: increment,
          });
        } else {
          // If the document exists, increment the points for the category
          int currentPoints = snapshot.data()?[category] ?? 0;
          transaction.update(userDoc, {
            category: currentPoints + increment,
          });
        }
      });
    } catch (e) {
      //print('Error updating points: $e');
      throw Exception('Failed to update points for category $category');
    }
  }

  static Future<List<Drummer>> getBandMembers() async {
    //print("getQuestionsAsked triggered");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userInterests = prefs.getStringList('interestList')!;

    var data = await FirebaseFirestore.instance
        .collectionGroup('mybands')
        .where("category", whereIn: userInterests)
        .get();

    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static Future<List<Jam>> getJamsFromBand(String bandId) async {
    //print("getJamsFromBand triggered");
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
    //print("getDrummsFromBands triggered");

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    DateTime currentTime = DateTime.now();

    // Calculate the time one minute ago
    DateTime oneMinuteAgo = currentTime.subtract(Duration(minutes: 1));

    List bandCategoryList = [];
    for (Band band in fetchedBands) {
      ////print("${band.name}");
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

    ////print("Jams list size ${fetchedList.length} ///////////////////////// ");
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      //if (isTimestampWithin1Minute(jam.lastActive ?? Timestamp.now())) {
      filterList.add(jam);
      //}
    }
    ////print("Filtered list size ${filterList.length} ///////////////////////// ");

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
    ////print("getJamsFromBand triggered");

    //if (fetchedBands.isEmpty)
    fetchedBands = await FirebaseDBOperations.getBandByUser();

    List bandCategoryList = [];
    for (Band band in fetchedBands) {
      bandCategoryList.addAll(band.hooks as Iterable);
    }
    if (bandCategoryList.isEmpty) {
      ////print("BandIDList is empty");
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

      //print('Document updated successfully');
    } catch (error) {
      //print('Error updating document: $error');
    }
  }

  static Future<List<Jam>> getJamsFromArticle(String articleId) async {
    //print("getJamsFromArticle triggered");
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
    //print("fetchedList size: ${fetchedList.length}");

    return filterList;
  }

  static Future<List<Jam>> getBroadcastJams() async {
    //print("getBroadcastJams triggered");
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('broadcast', isEqualTo: true)
        .get();

    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    return fetchedList;
  }

  static Future<List<Profession>> getProfessions() async {
    //print("getProfessions triggered");
    var data = await FirebaseFirestore.instance
        .collection('profession')
        .get();

    List<Profession> fetchedList =
    List.from(data.docs.map((e) => Profession.fromSnapshot(e)));
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
      //print("Error creating band: $error");
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
      //print("Error joining band: $error");
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
      //print("Error leaving band: $error");
      return false;
    }
  }

  static Future<List<Band>> getUserBands(String query) async {
    //print("getBands triggered");
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

    ////print("Getting Articles from Algolia ${getArticles.hits.elementAt(0).data["title"]}");
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
      //print("Error joining band: $error");
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
      //print("Error leaving band: $error");
      return false;
    }
  }

  static Future<List<Drummer>> getPeople(String query) async {
    //print("getPeople triggered");
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

    // AlgoliaQuerySnapshot getArticles =
    //     await algolia.instance.index('users').query(query).getObjects();
    //
    // ////print("Getting Articles from Algolia ${getArticles.hits.elementAt(0).data["title"]}");
    // List<Drummer> result = List.from(
    //     getArticles.hits.map((e) => Drummer.fromAlgoliaSnapshot(e.data)));

    return [];
  }

  static Future<Drummer> getDrummer(String uid) async {
    Drummer drummer = Drummer();
    // //print("getQuestionsAsked triggered");
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

  static Future<Stats> getDrummerStats(String uid) async {
    Stats stats = Stats();
     //print("getDrummerStats triggered");
    var data = await FirebaseFirestore.instance
        .collection('stats')
        .doc(uid)
        .get()
        .onError((error, stackTrace) {
      var data;
      DocumentSnapshot<Map<String, dynamic>> snapshot = data;
      //print("Stats does not exists");
      return snapshot;
    });
    if (data.exists) stats = Stats.fromSnapshot(data);

    return stats;
  }

  static Future<Article> getArticle(String articleId) async {
    Article article = Article();
    //print("getArticle triggered");
    var data = await FirebaseFirestore.instance
        .collection("stories")
        .doc(articleId)
        .get();
    article = Article.fromJson(data);
    //print("${data.data()}");

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

  static void subscribeToYourExpertise(String departmentName, String designation) async {
    subscribeToTopic(convertToValidTopicName(departmentName));
    subscribeToTopic(convertToValidTopicName(designation));
  }
  static void unsubscribeToYourExpertise(String departmentName, String designation) async {
    unsubscribeFromTopic(convertToValidTopicName(departmentName));
    unsubscribeFromTopic(convertToValidTopicName(designation));
  }

  static String convertToValidTopicName(String input) {
    // Replace spaces with a valid separator character, such as '_'
    String sanitized = input.replaceAll(' ', '_');

    // Ensure the length of the sanitized string is within the valid range
    const int maxLength = 900;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    // Ensure the sanitized string matches the pattern defined by _assertTopicName
    RegExp validPattern = RegExp(r'^[a-zA-Z0-9-_.~%]+$');
    sanitized = sanitized.replaceAll(RegExp(r'[^\w-_.~%]'), '');

    return sanitized;
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
    await messaging.unsubscribeFromTopic(topic).catchError((err){
      //print("Error while unsubscribing: $err ");
    });
    //print('Unsubscribed from topic: $topic');
  }

  static Future<void> sendRingingNotification(
      String deviceToken, Jam jam) async {
    var url = Uri.https('fcm.googleapis.com', '/v1/projects/drummapp/messages:send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    //print("${jam.toJson().toString()}");
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");

    // Fetch the access token
    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String authToken = await accessTokenGetter.getAccessToken();

    // Set headers
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    // Build the request body
    final body = jsonEncode({
      "message": {
        "token": deviceToken,  // Correctly use 'token' for targeting a device
        "notification": {
          "body": jam.title,
          "title": "Drumm Call",
          "image": "${drummer.imageUrl}"  // Remove 'sound' from here
        },
        "data": {
          "jam": jsonEncode(jam.toJson()),  // Convert jam object to JSON string
          "ring": true,
          "drummerID": uid ?? "",
          "open": true
        },
        "android": {
          "priority": "high",
          "notification": {
            "sound": "conga_drumm.caf"  // Android custom sound
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "conga_drumm.caf"  // iOS custom sound
            }
          },
          "headers": {
            "apns-priority": "10"
          }
        }
      }
    });

    // Send the notification
    var response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 200) {
      //print("Ringing notification sent successfully");
    } else {
      throw Exception('Failed to send calling notification');
    }
  }


  static Future<void> sendNotificationToDeviceToken(Jam jam) async {
    //print("Sending notification to device");

    var url = Uri.https('fcm.googleapis.com', '/v1/projects/drummapp/messages:send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
    String deviceToken = drummer.token ?? "";
    //print("Device Token is: ${deviceToken}");

    // Fetch the access token
    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String authToken = await accessTokenGetter.getAccessToken();

    // Set headers
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    String subtitle = "Hey ${drummer.username}! Did you know?";
    // Set lastActive to null as a workaround
    jam.lastActive = null;

    // Build the request body
    final body = jsonEncode({
      "message": {
        "token": deviceToken,  // Correctly use 'token' to send to a specific device
        "notification": {
          "body": (jam.question != null)
              ? "${jam.title}\n\n${jam.question}"
              : "${jam.title}",
          "title": subtitle,
          "image": "${jam.imageUrl}"  // Removed 'sound' from here
        },
        "data": {
          "jam": jsonEncode(jam.toJson()),  // Serialize the jam object
          "ring": false.toString(),
          "drummerID": uid ?? "",
          "open": true.toString(),
        },
        "android": {
          "priority": "high",
          "notification": {
            "sound": "conga_drumm.caf"  // Custom sound for Android
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "conga_drumm.caf"  // Custom sound for iOS
            }
          },
          "headers": {
            "apns-priority": "10"
          }
        }
      }
    });

    // Send the notification
    var response = await http.post(url, headers: header, body: body);

    // Check the response
    if (response.statusCode == 200) {
      //print("Notification sent successfully to device Token");
    } else {
      //print("Failed to send deviceToken notification ${response.statusCode}");
      throw Exception('Failed to send deviceToken notification ${response.statusCode}');
    }
  }


  static Future<void> sendNotificationToTopic(
      Jam jam, bool ring, bool open) async {

    try {
      //print("Sending notification to topic");
      //print("${jam.toJson().toString()}");

      var url = Uri.https(
          'fcm.googleapis.com', '/v1/projects/drummapp/messages:send');
      final uid = FirebaseAuth.instance.currentUser?.uid;
      Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
      bool isBroadcast = jam.broadcast ?? false;
      var topic = isBroadcast ? "creator" : '${jam.bandId}';

      // Fetch the access token
      AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
      String authToken = await accessTokenGetter.getAccessToken();

      //print("Auth Token received: $authToken");

      // Set headers
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Notification subtitle and body
      String subtitle = ring
          ? "${drummer.username} is drumming..."
          : isBroadcast
          ? "Welcome ${drummer.username} to Drumm"
          : "${drummer.username} is drumming...";

      var notificationBody = jam.question != null
          ? "${jam.question}\n\n${jam.title}"
          : jam.title;

      // Set lastActive to null as a workaround
      jam.lastActive = null;

      // Build the request body
      final body = jsonEncode({
        "message": {
          "topic": topic, // Correctly using 'topic' instead of 'token'
          "notification": {
            "body": notificationBody,
            "title": subtitle,
            "image": jam.imageUrl // Optional image
          },
          "data": {
            "jam": jsonEncode(jam.toJson()), // Serialize the jam object
            "ring": ring.toString(),
            "drummerID": uid ?? "",
            "open": open.toString(),
          },
          "android": {
            "priority": "high",
            "notification": {
              "sound": "conga_drumm.caf" // Custom sound for Android
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "conga_drumm.caf" // Custom sound for iOS
              }
            },
            "headers": {
              "apns-priority": "10"
            }
          }
        }
      });

      // Send the notification
      var response = await http.post(url, headers: header, body: body);

      // Check the response
      if (response.statusCode == 200) {
        //print("Notification sent successfully");
      } else {
        //print("Failed to send topic notification: ${response.statusCode}");
        //print("Error response body: ${response.body}");
        throw Exception(
            'Failed to send topic notification ${response.statusCode}');
      }
    }catch(e){
      //print("Error sending notification: $e");
    }
  }




  static Future<void> sendQuestionNotificationToTopic(Question question) async {
    //print("Sending notification to topic");

    var url = Uri.https('fcm.googleapis.com', '/v1/projects/drummapp/messages:send');
    Drummer drummer = await FirebaseDBOperations.getDrummer(question.uid ?? "");
    String departmentName = question.departmentName ?? "";
    String designation = question.designation ?? "";

    // Determine the topic name based on designation or departmentName
    String topicName = designation.isNotEmpty ? designation : departmentName;
    String topic = "/topics/$topicName";  // Correctly formatted topic name

    // Fetch the access token
    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String authToken = await accessTokenGetter.getAccessToken();

    // Set headers
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    String subtitle = "${drummer.username} wants to connect";
    var notificationBody = "${question.query}";

    // Build the request body
    final body = jsonEncode({
      "message": {
        "topic": topic,  // Correctly use 'topic' for sending to a topic
        "notification": {
          "body": notificationBody,
          "title": subtitle,
          "image": "${drummer.imageUrl}"  // Removed 'sound' from here
        },
        "data": {
          "question": jsonEncode(question.toJson()),  // Serialize the question object
          "drummer": jsonEncode(drummer.toJson()),    // Serialize the drummer object
          "open": true.toString()
        },
        "android": {
          "priority": "high",
          "notification": {
            "sound": "conga_drumm.caf"  // Custom sound for Android
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "conga_drumm.caf"  // Custom sound for iOS
            }
          },
          "headers": {
            "apns-priority": "10"
          }
        }
      }
    });

    // Send the notification
    var response = await http.post(url, headers: header, body: body);

    // Check the response
    if (response.statusCode == 200) {
      //print("Sent Notification for question");
    } else {
      //print("Failed to send topic notification ${response.statusCode}");
      throw Exception('Failed to send topic notification ${response.statusCode}');
    }
  }


  static Future<void> sendNotificationToDrummer(
      String deviceToken, Jam jam, bool ring, bool open) async {
    //print("Sending notification to drummer");

    var url = Uri.https('fcm.googleapis.com', '/v1/projects/drummapp/messages:send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
    bool isBroadcast = jam.broadcast ?? false;

    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String authToken = await accessTokenGetter.getAccessToken();

    // Set headers
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    String subtitle = (ring)
        ? "${drummer.username} is drumming..."
        : (isBroadcast)
        ? "Welcome ${drummer.username} to Drumm"
        : "${drummer.username} is drumming...";

    var notificationBody = (jam.question != null)
        ? "${jam.question}\n\n${jam.title}"
        : jam.title;

    // Set lastActive to null as a workaround
    jam.lastActive = null;

    // Build the request body
    final body = jsonEncode({
      "message": {
        "token": deviceToken,  // Correctly use 'token' for sending to a specific device
        if (!ring)
          "notification": {
            "body": notificationBody,
            "title": subtitle,
            "image": "${drummer.imageUrl}"  // Removed 'sound' from here
          },
        "data": {
          "jam": jsonEncode(jam.toJson()),  // Serialize the jam object
          "ring": ring.toString(),
          "drummerID": uid ?? "",
          "open": open.toString()
        },
        "android": {
          "priority": "high",
          "notification": {
            "sound": "conga_drumm.caf"  // Custom sound for Android
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "conga_drumm.caf"  // Custom sound for iOS
            }
          },
          "headers": {
            "apns-priority": "10"
          }
        }
      }
    });

    // Send the notification
    var response = await http.post(url, headers: header, body: body);

    // Check the response
    if (response.statusCode == 200) {
      //print("Notification sent to drummer");
    } else {
      //print("Failed to send notification ${response.statusCode}");
      throw Exception('Failed to send notification ${response.statusCode}');
    }
  }


  // Notification functions end

  static Future<Band> getBand(String bandId) async {
    Band band = Band();
    //print("getBand triggered");
    var data =
        await FirebaseFirestore.instance.collection('bands').doc(bandId).get();
    band = Band.fromSnapshot(data);
    //print("${data.data()}");

    return band;
  }

  static Future<List<Article>> getArticles(String query) async {
    //print("getArticles triggered");
    List<Article> emptyList = [];
    //searchArticles(query);
    if (query.length >= 3) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      var data = await FirebaseFirestore.instance
          .collection("stories")
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          // .doc(uid)
          // .collection('questions')
          //.orderBy('createdTime',descending: true)
          .get();
      //print(data.docs.length);
      return List.from(data.docs.map((e) => Article.fromJson(e)));
    } else {
      return emptyList;
    }
  }

  static Future<List<Article>> getArticlesByUser(String uid) async {
    //print("getArticles triggered");
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection("stories")
        .where('uid', isEqualTo: uid)
        // .doc(uid)
        // .collection('questions')
        //.orderBy('createdTime',descending: true)
        .get();
    //print(data.docs.length);
    return List.from(data.docs.map((e) => Article.fromJson(e)));
  }

  static Future<List<Drummer>> getUsersByBand(Band band) async {
    // Assuming you have already initialized the Firestore instance and have a reference to the "bands" collection
    String userID = FirebaseAuth.instance.currentUser!.uid;
    //print(userID);
    CollectionReference userbandsCollectionRef = FirebaseFirestore.instance
        .collection("bands")
        .doc(band.bandId)
        .collection("members");
    var bandsData = await userbandsCollectionRef.limit(5).get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)!["userId"].toString();
    }));
    //print(list.toString());

    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("users");

    // Define the userID you want to search for

    // Construct the query
    //print("getUsersByBand triggered");
    var data = await bandsCollectionRef.where("uid", whereIn: list).get();
    //print(data.docs.toString());

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
    //print(userID);
    CollectionReference userbandsCollectionRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("mybands");
    var bandsData = await userbandsCollectionRef.get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)!["bandId"].toString();
    }));
    //print("The user bands are ${list.toString()}");

    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("bands");

    // Define the userID you want to search for

    // Construct the query
    //print("getBandByUser triggered");
    if (list.isEmpty) {
      //print("bandsData list is null");
      return [];
    }
    try {
      var data = await bandsCollectionRef.where("bandId", whereIn: list).get();
      //print("Band fetched result ${data}");
      //print(data.docs.toString());

      // Execute the query
      return List.from(data.docs.map((e) => Band.fromSnapshot(e)));
    } catch (e) {
      //print("Unable to fetch bands because ${e.toString()}");
      return [];
    }
  }

  static Future<List<Article>> getArticlesByBandID(
      List<dynamic> bandHook) async {
    List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection("stories")
        .where('category', whereIn: bandHook)
        // .where('articleId', whereNotIn: seenPosts)
        .where('country', isEqualTo: 'us')
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
    //       .collection("stories")
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
    //print("getOnboardingBands triggered");
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
    //print(data.docs.toString());

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
    //   //print("Event!!!!!!!!! $event");
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
      //print('Jam data stored successfully in Realtime Database and Firestore.');
    }).catchError((error) {
      //print('Error storing Jam data in Firestore: $error');
    });
  }

  static void createOpenDrumm(Jam jam) {
    CollectionReference jamCollection =
        FirebaseFirestore.instance.collection('openDrumm');
    jamCollection
        .doc(jam.jamId ?? "")
        .set(jam.toJson(), SetOptions(merge: true))
        .then((_) {
      //print('Jam data stored successfully in Realtime Database and Firestore.');
    }).catchError((error) {
      //print('Error storing open data in Firestore: $error');
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
      //print("Unable to update device token${e}");
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
    });
  }

  static Future<bool> addMemberToJam(
      String jamId, String memberId, bool open) async {
    //print("adding Member from Jam $jamId");
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
        //print('Error while adding member: $onError');
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
    //       (value) => //print("DocumentSnapshot successfully updated!"),
    //   onError: (e) => //print("Error updating document $e"),
    // );
  }

  static void removeMemberFromJam(
      String jamId, String memberId, bool open) async {
    try {
      //print("removing Member from Jam $jamId");
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
            .onError((error, stackTrace) => null);

      } catch (err) {
        //print("jamId ${jamId}");
        //print("Error while removing member ${err}");
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
    });
  }


  static void updateLastOpened() async{
    DocumentReference drummerLastOpened =
    FirebaseFirestore.instance.collection('users').doc(getCurrentUserID());

    try {
      await drummerLastOpened.update({"lastOpened": Timestamp.now()});
    }catch(e){

    }
  }

  static Future<void> playMusicFromFirebase({
    required String firebaseStorageFilePath,
    required RtcEngine engine,             // Your initialized Agora engine
    bool loopback = false,                      // if local user should also hear the music
    bool replace = false,                       // false => music + mic; true => only music
    int cycle = 1,                              // how many times to loop the file
    int startPos = 0,                           // start position in milliseconds
  }) async {
    try {
      // 1. Obtain a reference to the Firebase Storage file
      //final ref = FirebaseStorage.instance.ref(firebaseStorageFilePath);

      // 2. Get a download URL
      //final downloadUrl = await ref.getDownloadURL();
      // NOTE: For large files, direct streaming might be tricky if 'startAudioMixing'
      //       does not accept a remote URL in your version.
      //       We'll demonstrate a local download approach here.

      // 3. Download the file to a local temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filename = firebaseStorageFilePath.split('/').last;
      // e.g. "my_music.mp3"
      final String localFilePath = '${tempDir.path}/$filename';

      // Use Dio to download
      final dio = Dio();
      await dio.download("https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/aivoice%2Fintroducing.mp3?alt=media&token=284dbee3-c3e0-48de-8a55-9d1b07a51d18", localFilePath);//await dio.download(downloadUrl, localFilePath);

      // 4. Start audio mixing with the just-downloaded local file
      await engine.startAudioMixing(
        filePath: localFilePath,
        loopback: loopback,
        cycle: cycle,
        startPos: startPos,
      );

      print('✅ Music download & mixing started successfully.');
    } catch (e) {
      print('❌ Failed to play music from Firebase: $e');
      rethrow;
    }
  }
  static Future<void> convertTextToSpeech(String text, String id, RtcEngine engine) async {
    print("Converting text to speech");
    try {
      //audioPlayer.stop();
      FirebaseDBOperations.OggOpus_Player.pause();
      FirebaseDBOperations.OggOpus_Player.dispose();
    } catch (e) {}
    final apiKey = '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';//'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';
    final endpoint = 'https://api.openai.com/v1/audio/speech';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Define a list of voices
    final voices = [
      //'alloy',
      //'fable',
      //'echo',
      //'onyx',
      //'nova',
      'shimmer'
    ]; //'echo', 'onyx', 'nova', 'shimmer'

    // Randomly select a voice from the list
    final random = Random();
    final selectedVoice = voices[random.nextInt(voices.length)];

    // Set the selected voice in the data
    final data = {
      'input': text,
      'model': 'tts-1',
      'voice': selectedVoice,
      //'response_format': 'opus',
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      //  //await audioPlayer.play(BytesSource(response.bodyBytes));
      final audioBytes = response.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      final audioFile = File('${appDir.path}/$id.mp3');
      await audioFile.writeAsBytes(audioBytes);
      //if (articleTop == id) {
      // audioPlayer.setFilePath(audioFile.path);
      // audioPlayer.play();

      await engine.startAudioMixing(
        filePath: audioFile.path,
        loopback: false,
        cycle: 1,
        startPos: 0,
      );





      //}
    } else {
      // Handle API error
      print("Error generating audio ${response.statusCode} ${response.body}");
      //createTTS(text);
    }
  }
}
