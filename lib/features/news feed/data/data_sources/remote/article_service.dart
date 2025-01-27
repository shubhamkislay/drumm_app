import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/news%20feed/data/models/article_list.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          .limit(20);

      if (getArticlesParams.lastDocument != null) {
        query = query.startAfterDocument(getArticlesParams.lastDocument!);
      } else {
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await query.get().onError((error, stackTrace) {
        throw DioException(
            requestOptions: RequestOptions(data: stackTrace),
            message: error.toString());
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
            message: "Unable to fetch articles"));
      }
    } on DioException catch (e) {
      print(e);
      return DataFailed(e);
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
}
