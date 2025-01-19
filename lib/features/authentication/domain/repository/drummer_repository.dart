import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/domain/entities/apple_credential.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class DrummerRepository{

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