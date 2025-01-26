import 'package:drumm_app/core/features/get%20drummer/data/data_sources/remote/drummer_service.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/data_sources/local/shared_preference_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/apple_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/auth_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/google_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/models/apple_credential.dart';
import 'package:drumm_app/core/features/get%20drummer/data/model/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final SharedPreferenceService sharedPreferenceService;
  final AppleSignInService appleSignInService;
  final GoogleSignInService googleSignInService;
  final DrummerService drummerService;

  AuthRepositoryImpl(this.authService, this.sharedPreferenceService,
      this.appleSignInService, this.googleSignInService, this.drummerService);

  @override
  Future<DataState<DrummerModel>> getDrummer(String uid) {
    return drummerService.getDrummer(uid: uid);
  }

  @override
  bool isAuthenticated() {
    return authService.isAuthenticated();
  }

  @override
  Future<bool> isOnboarded() {
    return sharedPreferenceService.isOnboarded();
  }

  @override
  void setOnboarded() {
    return sharedPreferenceService.setOnboarded();
  }

  @override
  Future<DataState<AppleCredentialModel>> getAppleCredential() {
    return appleSignInService.getAppleCredential();
  }

  @override
  Future<DataState<UserCredential>> getUserCredential(
      AuthCredential authCredential) {
    return authService.getUserCredential(authCredential);
  }

  @override
  DataState<String> getDrummerId() {
    return drummerService.getDrummerId();
  }

  @override
  Future<bool> selectedBands() {
    return sharedPreferenceService.selectedBands();
  }

  @override
  Future<DataState<OAuthCredential>> getGoogleCredential() {
    return googleSignInService.getGoogleCredential();
  }

  @override
  Future<DataState<bool>> isUserOnboarded() {
    return authService.isUserOnboarded();
  }

  @override
  void setAuthProvider(String authProvider) {
    return sharedPreferenceService.setAuthProvider(authProvider);
  }

  @override
  Future<String> getAuthProvider() {
    return sharedPreferenceService.getAuthProvider();
  }

}
