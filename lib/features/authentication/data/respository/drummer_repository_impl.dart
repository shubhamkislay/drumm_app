import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/data_sources/local/shared_preference_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/apple_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/firebase_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/google_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/models/apple_credential.dart';
import 'package:drumm_app/features/authentication/data/models/drummer.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class DrummerRepositoryImpl implements DrummerRepository {
  final FirebaseService firebaseService;
  final SharedPreferenceService sharedPreferenceService;
  final AppleSignInService appleSignInService;
  final GoogleSignInService googleSignInService;

  DrummerRepositoryImpl(this.firebaseService, this.sharedPreferenceService,
      this.appleSignInService, this.googleSignInService);

  @override
  Future<DataState<DrummerModel>> getDrummer(String uid) {
    return firebaseService.getDrummer(uid);
  }

  @override
  bool isAuthenticated() {
    return firebaseService.isAuthenticated();
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
    return firebaseService.getUserCredential(authCredential);
  }

  @override
  DataState<String> getDrummerId() {
    return firebaseService.getDrummerId();
  }

  @override
  Future<bool> selectedBands() {
    return sharedPreferenceService.selectedBands();
  }

  @override
  Future<DataState<OAuthCredential>> getGoogleCredential() {
    return googleSignInService.getGoogleCredential();
  }
}
