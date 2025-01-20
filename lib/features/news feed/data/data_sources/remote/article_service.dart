import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArticleService{
  Future<DataState<List<ArticleModel>>> getArticles(List<String> category) async {
    try {
        late Query<Map<String, dynamic>> query = FirebaseFirestore.instance
            .collection("stories")
            .where('category', whereIn: category)
            .where('country', isEqualTo: 'us')
            .where('publishedAt', isNotEqualTo: null)
            .orderBy("publishedAt", descending: true)
            .limit(10);

        final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get().onError((error, stackTrace){
          throw DioException(
              requestOptions: RequestOptions(data: stackTrace),
              message: error.toString());
        });
        if (snapshot.docs.isNotEmpty) {
          List<ArticleModel> newArticles = snapshot.docs.map((doc) => ArticleModel.fromDocumentSnapshot(doc)).toList();
          return DataSuccess(newArticles);
        } else {
          return DataFailed(DioException(requestOptions: RequestOptions(),message: "Unable to fetch articles"));
        }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  Future<DataState<List<String>>> getBandsCategoryList() async{
    CollectionReference userBandsCollectionRef = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid??"")
        .collection("mybands");
    var bandsData = await userBandsCollectionRef.get();
    List<String> list = List.from(bandsData.docs.map((e) {
      return (e.data() as Map)["bandId"].toString();
    }));

    return DataSuccess(list);

  }

}