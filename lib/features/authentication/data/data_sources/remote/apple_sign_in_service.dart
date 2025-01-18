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
  }
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}