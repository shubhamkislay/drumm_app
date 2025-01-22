import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/models/apple_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/features/get drummer/data/model/drummer.dart';

class AuthService {
  Future<DataState<UserCredential>> getUserCredential(
      AuthCredential authCredential) async {
    await FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((value) {
      if (value.credential != null) {
        return DataSuccess(value);
      } else {
        return DataFailed(DioException(
            message: "Null credential received from auth provider!",
            requestOptions: RequestOptions()));
      }
    });
    return DataFailed(DioException(
        message: "Null credential received from auth provider!",
        requestOptions: RequestOptions()));
  }

  bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }
  Future<DataState<bool>> isUserOnboarded() async {
    try {
      var userID = FirebaseAuth.instance.currentUser!.uid;

      CollectionReference userBandsCollectionRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .collection("mybands");
      var bandsData = await userBandsCollectionRef.get();
      List<String> list = List.from(bandsData.docs.map((e) {
        return (e.data() as Map)["bandId"].toString();
      }));
      if (list.isEmpty) {
        return DataSuccess(false);
      } else {
        return DataSuccess(true);
      }
    } on DioException catch (e) {
      return DataFailed(DioException(
          requestOptions: RequestOptions(),
          message: "Failed to check user is user onboarded or not"));
    }
  }
}
