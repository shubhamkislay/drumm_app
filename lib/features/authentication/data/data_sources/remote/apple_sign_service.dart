import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/models/apple_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService{


  Future<DataState<AppleCredentialModel>> getAppleCredential() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    AuthorizationCredentialAppleID appleCredential;
    // Request credential for the currently signed in Apple account.
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
    } catch (e) {
      return DataFailed(DioException(message: e.toString(), requestOptions: RequestOptions()));
    }
    return DataSuccess(AppleCredentialModel(appleCredential,rawNonce));

    // FirebaseAuth.instance.signInWithCredential(oauthCredential).then((value) {
    //   if (value.credential != null) {
    //     checkIfUserExistsApple(value, "apple",appleCredential);
    //   }
    //   else {
    //     setState(() {
    //       signingIn = false;
    //       signingIN = "";
    //       apple = "Continue with Apple";
    //     });
    //     return DataFailed(DioException(message: "Null credential received from auth provider!", requestOptions: RequestOptions()));
    //   }
    // });
    // signin.then((value) => {checkIfUserExists(value)});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}