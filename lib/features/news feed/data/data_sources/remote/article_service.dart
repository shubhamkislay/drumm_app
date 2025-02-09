import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/news%20feed/data/models/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ArticleService {
  Future<DataState<ArticleListModel>> getArticles(
      GetArticlesParams getArticlesParams) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("recommendations")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("articles")
          .where('category', whereIn: getArticlesParams.category)
          .where('isRepresentative', isEqualTo: true)
          .orderBy("recommendedTimestamp", descending: true)
          .limit(15);

      if (getArticlesParams.lastDocument != null) {
        query = query.startAfterDocument(getArticlesParams.lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await query.get().onError((error, stackTrace) {
        throw DioException(
            requestOptions: RequestOptions(data: stackTrace),
            message: "Error fetching file: ${error.toString()}");
      });
      if (snapshot.docs.isNotEmpty) {
        List<ArticleModel> newArticles = snapshot.docs
            .map((doc) => ArticleModel.fromDocumentSnapshot(doc))
            .toList();
        return DataSuccess(ArticleListModel(
            articleList: newArticles, lastDocument: snapshot.docs.last));
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message: "There aren't any articles for this band."));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  Future<DataState<ArticleListModel>> getLatestArticles(
      GetArticlesParams getArticlesParams) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("stories")
          .where('category', whereIn: getArticlesParams.category)
          .where('isRepresentative', isEqualTo: true)
          .orderBy("publishedAt", descending: true)
          .limit(15);

      if (getArticlesParams.lastDocument != null) {
        query = query.startAfterDocument(getArticlesParams.lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await query.get().onError((error, stackTrace) {
        throw DioException(
            requestOptions: RequestOptions(data: stackTrace),
            message: "Error fetching file: ${error.toString()}");
      });
      if (snapshot.docs.isNotEmpty) {
        List<ArticleModel> newArticles = snapshot.docs
            .map((doc) => ArticleModel.fromDocumentSnapshot(doc))
            .toList();
        return DataSuccess(ArticleListModel(
            articleList: newArticles, lastDocument: snapshot.docs.last));
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message: "There aren't any articles for this band."));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  Future<DataState<ArticleListModel>> performVectorSearch(
      GetArticlesParams getArticlesParams) async {
    try {
      // Create a callable reference to the vectorSearch Cloud Function
      print("Perform vector search");

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('vectorSearch');

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      Timestamp recommendTimestamp = getArticlesParams.drummerEntity!.lastRecommendationTimestamp ?? Timestamp.fromDate(DateTime(2000));

      //print('The user Id is : $userId');

      // Call the Cloud Function with userId and limit
      final result = await callable.call({
        'userId': userId??"",
        'limit': 25,
        'preference' :getArticlesParams.drummerEntity!.preference?.toArray(),
        'recommendTimestamp':recommendTimestamp.millisecondsSinceEpoch.toString()
      });

      ////print('Raw response from Cloud Function: ${result.data['articles'][0]}');

      // Parse the response
      final List<ArticleModel> articles =
      (result.data['articles'] as List<dynamic>)
          .map((articleData) => ArticleModel.fromCloudFunction(articleData))
          .toList();

      generateRecommendation(recommendTimestamp);
      return DataSuccess(ArticleListModel(articleList: articles,));
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }

  void generateRecommendation(Timestamp recommendTimestamp) async {
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

  Future<DataState<bool>> generateAndLoadRecommendedArticles(GetArticlesParams getArticlesParams) async {
    try {
      Timestamp recommendTimestamp = getArticlesParams.drummerEntity!.lastRecommendationTimestamp ?? Timestamp.fromDate(DateTime(2000));
      print("Calling generateRecommendation function");
      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('generateRecommendations');

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final result = await callable.call({
        'userId': userId??"",
        'recommendTimestamp':recommendTimestamp.millisecondsSinceEpoch.toString()??"",
      });
     return DataSuccess(true);
    } catch (error) {
      return DataSuccess(false);
    }
  }

  Future<DataState<bool>> vectorSearchAndLoadRecommendedArticles(GetArticlesParams getArticlesParams) async {
    try {
      Timestamp recommendTimestamp = getArticlesParams.drummerEntity!.lastRecommendationTimestamp ?? Timestamp.fromDate(DateTime(2000));
      print("Calling vectorSearchAndStore function");
      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('vectorSearchAndStore');

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final result = await callable.call({
        'userId': userId??"",
        'limit': 25,
        'preference' :getArticlesParams.drummerEntity!.preference?.toArray(),
        'recommendTimestamp':recommendTimestamp.millisecondsSinceEpoch.toString()
      });
      return DataSuccess(true);
    } catch (error) {
      return DataSuccess(false);
    }
  }

  Future<DataState<List<String>>> getBandsCategoryList() async {
    CollectionReference userBandsCollectionRef = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .collection("mybands");
    var bandsData = await userBandsCollectionRef.get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)["bandId"].toString();
    }));

    return DataSuccess(list);
  }

  Future<DataState<ArticleListModel>> getClusteredArticles(
      ArticleEntity article) async {
    List<ArticleModel> clusteredArticles = [];
    clusteredArticles.add(article as ArticleModel);

    DocumentSnapshot<Map<String, dynamic>> articleSnapshot =
        await FirebaseFirestore.instance
            .collection('stories')
            .doc(article.articleId)
            .get();

    if (!articleSnapshot.exists) {
      return DataFailed(DioException(
          requestOptions: RequestOptions(), message: "Cannot find article"));
    }

    ArticleModel updatedArticle =
        ArticleModel.fromDocumentSnapshot(articleSnapshot);

    if (updatedArticle.clusterId == null) {
      if (kDebugMode) {
        print("Article is not part of any cluster");
      }

      return DataSuccess(ArticleListModel(articleList: clusteredArticles));
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection("stories")
        .where('clusterId', isEqualTo: updatedArticle.clusterId)
        .where('isRepresentative', isEqualTo: false)
        .orderBy("publishedAt", descending: true);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      clusteredArticles = snapshot.docs
          .map((doc) => ArticleModel.fromDocumentSnapshot(doc))
          .toList();
    } else {
      print('Nothing found');
    }

    return DataSuccess(ArticleListModel(
        articleList: clusteredArticles, lastDocument: snapshot.docs.last));
  }

  Future<DataState<ArticleListModel>> getSimilarArticles(
      GetSimilarArticlesParams params) async {
    try {
      // Create a callable reference to the vectorSearch Cloud Function

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('semanticSearch');

      //print('The user Id is : $userId');

      // Call the Cloud Function with userId and limit
      final result = await callable
          .call({'limit': 5, 'embedding': params.embedding?.toArray()});

      ////print('Raw response from Cloud Function: ${result.data['articles'][0]}');

      // Parse the response
      final List<ArticleModel> articles =
          (result.data['articles'] as List<dynamic>)
              .map((articleData) => ArticleModel.fromCloudFunction(articleData))
              .toList();

      articles.removeWhere((similarArticle) =>
          similarArticle.articleId == params.article!.articleId);
      return DataSuccess(ArticleListModel(articleList: articles));
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }

  Future<int> getInteractionsCount() async {
    try {
      CollectionReference interactionsRef = FirebaseFirestore.instance
          .collection('userActivity')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('interactions');

      QuerySnapshot snapshot = await interactionsRef.get();

      return snapshot.size; // Returns the number of documents in the collection
    } catch (e) {
      print('Error fetching interactions count: $e');
      return 0; // Returns 0 in case of an error
    }
  }
}
