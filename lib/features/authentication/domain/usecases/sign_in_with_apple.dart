import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecases/usecase.dart';
import 'package:drumm_app/features/authentication/domain/entities/apple_credential.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/entities/user_auth_details.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SignInWithAppleUseCase implements UseCase<DataState<String>, void> {
  final DrummerRepository drummerRepository;

  SignInWithAppleUseCase(this.drummerRepository);

  @override
  Future<DataState<String>> call({void params}) async {
    try {
      var route = "/";

      var appleAuthDataState = await drummerRepository.getAppleCredential();

      if (appleAuthDataState is DataSuccess) {
        var userCredentialState = await drummerRepository
            .getUserCredential(createOAuthCredential(appleAuthDataState.data!));

        var userIdState = drummerRepository.getDrummerId();

        var drummerState =
            await drummerRepository.getDrummer(userIdState.data!);

        String? uname = drummerState.data?.username!;


        if (userExists(uname ?? "")) {
          bool selectedBands = await drummerRepository.selectedBands();
          if (selectedBands) {
            route = "/newsDiscovery";
          } else {
            route = "/interestsPage";
          }
        } else {
          String displayName = getDisplayName(appleAuthDataState.data!);
          String? email = userCredentialState.data?.user?.email;
          route = "/register?name=$displayName/email=${email}";
        }
        return DataSuccess(route);
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message:
                "Failed to get Apple credential. ${appleAuthDataState.error!.message}"));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  OAuthCredential createOAuthCredential(
      AppleCredentialEntity appleCredentialEntity) {
    final appleOauthProvider = OAuthProvider(
      "apple.com",
    );
    appleOauthProvider.setScopes([
      'email',
      'name',
    ]);
    final oauthCredential = appleOauthProvider.credential(
      idToken: appleCredentialEntity.appleCredential.identityToken,
      accessToken: appleCredentialEntity.appleCredential.authorizationCode,
      rawNonce: appleCredentialEntity.rawNonce,
    );

    return oauthCredential;
  }

  String getDisplayName(AppleCredentialEntity appleCredentialEntity) {
    var fixDisplayNameFromApple = "";

    try {
      fixDisplayNameFromApple = [
        appleCredentialEntity.appleCredential.givenName ?? '',
        appleCredentialEntity.appleCredential.familyName ?? '',
      ].join(' ').trim();
    } catch (e) {
      if (kDebugMode) print("getDisplayName : $e");
    }

    return fixDisplayNameFromApple;
  }

  bool userExists(String uname) {
    return uname.isNotEmpty;
  }
}
