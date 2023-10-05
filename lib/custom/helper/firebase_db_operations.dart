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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../model/band.dart';

typedef void UpdateCallback();

typedef void JamCallback(Jam jam);

class FirebaseDBOperations {
  static var listener;

  static Algolia algolia = Algolia.init(
    applicationId: '6GGZ3SNOXT',
    apiKey: '556ea147474872eb56f4fa0d31ad71eb',
  );

  static List<Article> exploreArticles = [];

  static DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  static Future<List<Article>> searchArticles(String query) async {
    AlgoliaQuerySnapshot getArticles =
        await algolia.instance.index('articles').query(query).getObjects();

    print(
        "Getting Articles from Algolia ${getArticles.hits.elementAt(0).data["title"]}");
    List<Article> result =
        List.from(getArticles.hits.map((e) => Article.fromSnapshot(e.data)));
    if (query.isEmpty) exploreArticles = result;

    return result;
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

      batch.update(articleRef, {'likes': FieldValue.increment(1)});
      batch.set(userLikeRef, {'liked': true});

      await batch.commit();
      return true;
    } catch (error) {
      print("Error updating like status: $error");
      return false;
    }
  }

  static Future<bool> updateCount(String? jamID,int count) async {

    final DocumentReference jams = FirebaseFirestore.instance
        .collection("jams")
        .doc(jamID);

    final DocumentReference openDrumms = FirebaseFirestore.instance
        .collection("openDrumm")
        .doc(jamID);

    jams.update({'count': count});
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

      batch.update(articleRef, {'likes': FieldValue.increment(-1)});
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

  static Future<List<String>> fetchSeenList() async {
    final String currentUserID = getCurrentUserID();
    try {
      final QuerySnapshot userSeenSnapshot = await FirebaseFirestore.instance
          .collection("userActivity")
          .doc(currentUserID)
          .collection("seen")
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
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
        //.orderBy('createdTime',descending: true)
        .get();
    return List.from(data.docs.map((e) => Question.fromSnapshot(e)));
  }

  static Future<List<Question>> getQuestionsAsked() async {
    print("getQuestionsAsked triggered");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userInterests = prefs.getStringList('interestList')!;

    var data = await FirebaseFirestore.instance
        .collectionGroup('questions')
        .where("category", whereIn: userInterests)
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
        .collection('jams')
        .where('bandId', isEqualTo: bandId)
        .get();
    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      int memLen = jam.membersID?.length ?? 0;
      if (memLen > 0) {
        filterList.add(jam);
      }
    }

    return filterList;
  }

  static Future<List<Jam>> getDrummsFromBands() async {
    print("getDrummsFromBands triggered");

    List<Band> bandsList = await FirebaseDBOperations.getBandByUser();

    print("bandsList: $bandsList");

    List<String> bandIDList = [];
    for (Band band in bandsList) {
      bandIDList.add(band.bandId ?? "");
    }
    if (bandIDList.isEmpty) return [];
    var data = await FirebaseFirestore.instance
        .collection('jams')
        .where('bandId', whereIn: bandIDList)
        .where('broadcast', isEqualTo: false)
        .where('count', isGreaterThan:0)
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

    return List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
  }

  static Future<List<Jam>> getOpenDrummsFromBands() async {
    print("getJamsFromBand triggered");

    List<Band> bandsList = await FirebaseDBOperations.getBandByUser();

    print("bandsList: $bandsList");

    List<String> bandIDList = [];
    for (Band band in bandsList) {
      bandIDList.add(band.bandId ?? "");
    }
    if (bandIDList.isEmpty) return [];
    var data = await FirebaseFirestore.instance
        .collection('openDrumm')
        .where('bandId', whereIn: bandIDList)
        .where('broadcast', isEqualTo: false)
        .where('count', isGreaterThan:0)
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

    return List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
  }

  static Future<List<Jam>> getJamsFromArticle(String articleId) async {
    print("getJamsFromArticle triggered");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection('jams')
        .where('articleId', isEqualTo: articleId)
        .get();

    List<Jam> fetchedList =
        List.from(data.docs.map((e) => Jam.fromSnapshot(e)));
    List<Jam> filterList = [];
    for (Jam jam in fetchedList) {
      int memLen = jam.membersID?.length ?? 0;
      if (memLen > 0) {
        filterList.add(jam);
      }
    }

    return filterList;
  }

  static Future<List<Jam>> getBroadcastJams() async {
    print("getBroadcastJams triggered");
    var data = await FirebaseFirestore.instance
        .collection('jams')
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

  /**
   * Notification functions start
   */
  static void subscribeToTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
    await messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  static void subscribeToUserBands() async {
    List<Band> userBands = await FirebaseDBOperations.getBandByUser();
    for (Band band in userBands) {
      FirebaseDBOperations.subscribeToTopic(band.bandId ?? "");
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
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
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      /*List<dynamic> list = json['choices'];
    String searchResult = list[0]["text”];*/
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception('Failed to send calling notification');
    }
  }

  static Future<void> sendNotificationToTopic(
      Jam jam, bool ring, bool open) async {
    print("Sending notification");
    var url = Uri.https('fcm.googleapis.com', '/fcm/send');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Drummer drummer = await FirebaseDBOperations.getDrummer(uid ?? "");
    String toParams = "/topics/" + '${jam.bandId}';

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAA8pEyjik:APA91bFjoRwCsioHAgDsWYHhcmy63BQuxL3iUBBaYnE9s2SHMnJtl0oyD39Mdp0KphI53ldusblYoiCCvxNaKJEFVQbGVTrwMcqDu9w_Rpx_Vsjx_9TdE3xI54vqj0lNOPDqAb5GPwOp'
    };

    String type = "notification";
    String subtitle = (ring)
        ? "${drummer.username} started a drumm"
        : "${drummer.username} joined the drumm";
    if (ring) type = "data";
    final body = jsonEncode({
      "to": "${toParams}",
      //if (!ring)
        "notification": {
          "body": jam.title,
          "title": subtitle,
          "image": "${jam.imageUrl}"
        },
      "priority": "high",
      "content_available": true,
      "mutable_content": true,
      "data": {"jam": jam, "ring": ring, "drummerID": uid, "open": open}
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

  /**
   * Notification functions end
   */

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
    } else
      return emptyList;
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
    print(list.toString());

    CollectionReference bandsCollectionRef =
        FirebaseFirestore.instance.collection("bands");

    // Define the userID you want to search for

    // Construct the query
    print("getBandByUser triggered");
    if (list.isEmpty) return [];
    var data = await bandsCollectionRef.where("bandId", whereIn: list).get();
    print(data.docs.toString());

    // Execute the query
    return List.from(data.docs.map((e) => Band.fromSnapshot(e)));
  }

  static Future<List<Article>> getArticlesByBands() async {
    List<Band> fetchedBands = await FirebaseDBOperations.getBandByUser();
    List<String> bandCategoryList = [];
    for (Band band in fetchedBands) {
      bandCategoryList.add(band.bandId ?? "");
    }
    if (fetchedBands.length < 1) bandCategoryList.add("general");

    //print("Fetched interesets: ${userInterests.toString()}");
    //print("Fetched categories: ${bandCategoryList.toString()}");
    List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();
    //if(seenPosts.isEmpty)

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', whereIn: bandCategoryList)
       // .where('country', isEqualTo: 'in')
        .where('source', isNotEqualTo: null)
        .orderBy("publishedAt", descending: true)
        .limit(50);

    List<Article> filterArticle = [];
    bool checkedEverything = false;

    while(filterArticle.length<1&&!checkedEverything) {
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      if(snapshot.docs.isNotEmpty)
        lastDocument = snapshot.docs.last;
      List<Article> newArticles =
      snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
      if(newArticles.length<1) {
        checkedEverything = true;
      }
      for (Article article in newArticles) {
        if (!seenPosts.contains(article.articleId)|| checkedEverything)
          filterArticle.add(article);

      }
    }

    ///Uncomment the below code if you want to replay the articles after you have seen everything
    // if(filterArticle.length<1&&checkedEverything){
    //   Query<Map<String, dynamic>> query = FirebaseFirestore.instance
    //       .collection('articles')
    //       .where('category', whereIn: bandCategoryList)
    //   // .where('country', isEqualTo: 'in')
    //       .where('source', isNotEqualTo: null)
    //       .orderBy("publishedAt", descending: true)
    //       .limit(50);
    //   final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    //   filterArticle = snapshot.docs.map((doc) => Article.fromJson(doc)).toList();
    // }

    return filterArticle;
  }

  static Future<List<Article>> getArticlesByBandID(String bandID) async {
    List<String> seenPosts = await FirebaseDBOperations.fetchSeenList();

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('articles')
        .where('category', isEqualTo: bandID)
       // .where('articleId', whereNotIn: seenPosts)
        //.where('country', isEqualTo: 'in')
        .where('source', isNotEqualTo: null)
        .orderBy("publishedAt", descending: true)
        .limit(50);

    List<Article> filterArticle = [];
    bool checkedEverything = false;
    while(filterArticle.length<1&&!checkedEverything) {

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    if(snapshot.docs.isNotEmpty)
      lastDocument = snapshot.docs.last;

    List<Article> newArticles =
    snapshot.docs.map((doc) => Article.fromJson(doc)).toList();

    if(newArticles.length<1)
      checkedEverything = true;

    for (Article article in newArticles) {
      if (!seenPosts.contains(article.articleId)||checkedEverything)
        filterArticle.add(article);
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
    if (open)
      path = "openDrumm";
    else
      path = "jams";

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
        FirebaseFirestore.instance.collection('jams');
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

  static void addMemberToRoom(String jamId, String memberId) async {
    DocumentReference memberRef =
        FirebaseFirestore.instance.collection("jams").doc(jamId);

    final sfDocRef = FirebaseFirestore.instance.collection("jams").doc(jamId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(memberRef);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      Jam jam = Jam.fromDocListenSnapshot(snapshot);
      final count = snapshot.get("count") + 1;
      List<dynamic> memList = jam.membersID ?? [];
      if (!memList.contains(FirebaseAuth.instance.currentUser?.uid ?? ""))
        memList.add(FirebaseAuth.instance.currentUser?.uid ?? "");
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
      if (open)
        path = "openDrumm";
      else
        path = "jams";
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

    // final sfDocRef = FirebaseFirestore.instance.collection("jams").doc(jamId);
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

      if (open)
        path = "openDrumm";
      else
        path = "jams";
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
        FirebaseFirestore.instance.collection("jams").doc(jamId);

    final sfDocRef = FirebaseFirestore.instance.collection("jams").doc(jamId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(memberRef);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      Jam jam = Jam.fromDocListenSnapshot(snapshot);
      final count = snapshot.get("count") - 1;
      List<dynamic> memList = jam.membersID ?? [];
      if (memList.contains(FirebaseAuth.instance.currentUser?.uid ?? ""))
        memList.remove(FirebaseAuth.instance.currentUser?.uid ?? "");
      transaction.update(sfDocRef,
          {"count": count, "membersID": memList}); //,"membersID":memList
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"),
    );
  }
}
