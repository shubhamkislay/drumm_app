import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';

import '../../models/drummer.dart';

class FirebaseService{

  Future<DataState<DrummerModel>> getDrummer(String uid) async {
    print("uid passed $uid");
    try {
      DrummerModel drummerModel = DrummerModel();
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .onError((error, stackTrace) {
            throw DioException(requestOptions:  RequestOptions(data: stackTrace),message: error.toString());
      });
      if (data.exists) {
        drummerModel = DrummerModel.fromDocumentSnapshot(data);
        return DataSuccess(drummerModel);
      } else {
        return DataFailed(DioException(message: "This drummer does not Exist!",
            requestOptions: RequestOptions(data: data)));
      }
    }on DioException catch(e){
      return DataFailed(e);
    }
  }
}