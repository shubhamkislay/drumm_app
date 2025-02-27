import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/features/get%20drummer/data/model/drummer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrummerService{
  Future<DataState<DrummerModel>> getDrummer({String ? uid}) async {
    print("getDrummer called from DrummerService////");

    late String userId;
    if(uid==null||uid.isEmpty){
      userId = FirebaseAuth.instance.currentUser!.uid;
    }else{
      userId = uid;
    }
    try {
      DrummerModel drummerModel = DrummerModel();
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .onError((error, stackTrace) {

        print("Error occured while fetching ${error.toString()}");

        throw DioException(
            requestOptions: RequestOptions(data: stackTrace),
            message: error.toString());
      });
      if (data.exists) {
        drummerModel = DrummerModel.fromDocumentSnapshot(data);
        print("Drummer fetched ${drummerModel.toJson().toString()}");

        return DataSuccess(drummerModel);
      } else {

        print("Drummer does not exist");

        return DataFailed(DioException(
            message: "This drummer does not Exist!",
            requestOptions: RequestOptions(data: data)));
      }
    } on DioException catch (e) {
      print("Error fetching drummer $e");
      return DataFailed(e);
    }
  }

  Future<DataState<DrummerModel>> getDrummerByRid({int ? rid}) async {

    late Query<Map<String, dynamic>> query;
      query = FirebaseFirestore.instance
          .collection("users")
          .where("rid", isEqualTo: rid).limit(1);

    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await query.get().onError((error, stackTrace) {
      throw DioException(
          requestOptions: RequestOptions(data: stackTrace),
          message: error.toString());
    });
    if (snapshot.docs.isNotEmpty) {
      List<DrummerModel> drummer = snapshot.docs
          .map((doc) => DrummerModel.fromDocumentSnapshot(doc))
          .toList();
      return DataSuccess(drummer.elementAt(0));
    } else {
      return DataFailed(DioException(
          requestOptions: RequestOptions(),
          message: "Unable to fetch bands"));
    }
  }

  DataState<String> getDrummerId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return DataFailed(DioException(
          requestOptions: RequestOptions(),
          message: "Unable to get user Id. User may not authenticated"));
    } else {
      return DataSuccess(uid);
    }
  }
}