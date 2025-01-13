import 'package:drumm_app/features/authentication/domain/entities/apple_credential.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleCredentialModel extends AppleCredentialEntity {
  AuthorizationCredentialAppleID appleCredential;
  String rawNonce;

  AppleCredentialModel(this.appleCredential, this.rawNonce) : super(appleCredential, rawNonce);
}