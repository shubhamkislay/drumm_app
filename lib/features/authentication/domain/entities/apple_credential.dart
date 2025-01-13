import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleCredentialEntity {
  AuthorizationCredentialAppleID appleCredential;
  String rawNonce;

  AppleCredentialEntity(this.appleCredential, this.rawNonce);
}