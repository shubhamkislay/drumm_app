import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/domain/entities/apple_credential.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository{

  Future<DataState<DrummerEntity>> getDrummer(String uid);

  DataState<String> getDrummerId();

  bool isAuthenticated();

  Future<bool> isOnboarded();

  Future<bool> selectedBands();

  void setOnboarded();

  Future<DataState<AppleCredentialEntity>> getAppleCredential();

  Future<DataState<OAuthCredential>> getGoogleCredential();

  Future<DataState<UserCredential>> getUserCredential(AuthCredential authCredential);

  Future<DataState<bool>> isUserOnboarded();

}