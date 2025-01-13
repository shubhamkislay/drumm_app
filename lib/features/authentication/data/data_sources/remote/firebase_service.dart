import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/models/apple_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<DataState<UserCredential>> getUserCredential(AuthCredential authCredential) async{
    await FirebaseAuth.instance.signInWithCredential(authCredential).then((value) {
      if (value.credential != null) {
       return DataSuccess(value);
      }
      else {
        return DataFailed(DioException(message: "Null credential received from auth provider!", requestOptions: RequestOptions()));
      }
    });
    return DataFailed(DioException(message: "Null credential received from auth provider!", requestOptions: RequestOptions()));
  }

  DataState<String> getDrummerId(){

    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid;
    if(uid == null){
      return DataFailed(DioException(requestOptions: RequestOptions(),message: "Unable to get user Id. User may not authenticated"));
    } else{
      return DataSuccess(uid);
    }

  }

  bool isAuthenticated(){
    return FirebaseAuth.instance.currentUser != null;
  }
}