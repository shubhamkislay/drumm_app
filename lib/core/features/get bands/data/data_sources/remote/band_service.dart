import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20bands/data/model/band.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BandService{

  Future<DataState<List<BandModel>>> getCurrentUserBands() async{
    try {
      CollectionReference userBandsCollectionRef = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
          .collection("mybands");
      var bandsData = await userBandsCollectionRef.get();
      List<String> list = List.from(bandsData.docs.map((e) {
        return (e.data() as Map)["bandId"].toString();
      }));

      var getBandsDataState = await getBands(bandIds: list);
      if (getBandsDataState is DataSuccess) {
        return DataSuccess(getBandsDataState.data ?? []);
      } else {
        return DataFailed(getBandsDataState.error ?? DioException(
            requestOptions: RequestOptions(), message: "Failed to fetch band"));
      }
    } on DioException catch(e){
      return DataFailed(e);
    }


  }

  Future<DataState<List<BandModel>>> getBands({List<String> ? bandIds})async{
    try {
      late Query<Map<String, dynamic>> query;

      if (bandIds == null || bandIds.isEmpty) {
        query = FirebaseFirestore.instance
            .collection("bands");
      } else {
        query = FirebaseFirestore.instance
            .collection("bands")
            .where("bandId", whereIn: bandIds);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await query.get().onError((error, stackTrace) {
        throw DioException(
            requestOptions: RequestOptions(data: stackTrace),
            message: error.toString());
      });
      if (snapshot.docs.isNotEmpty) {
        List<BandModel> bands = snapshot.docs
            .map((doc) => BandModel.fromDocumentSnapshot(doc))
            .toList();
        return DataSuccess(bands);
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message: "Unable to fetch bands"));
      }
    }on DioException catch(e){
      return DataFailed(e);
    }
  }

}