import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService{

  Future<DataState<OAuthCredential>> getGoogleCredential() async{

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      var credential;
      try {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
      } catch (e) {
        if (kDebugMode) {
          print("Exception returned ${e.toString()}");
        }

        return DataFailed(DioException(
            requestOptions: RequestOptions(), message: e.toString()));
      }

      return DataSuccess(credential);
    }on DioException catch(e){
      return DataFailed(DioException(
          requestOptions: RequestOptions(), message: e.toString()));
    }
  }

}