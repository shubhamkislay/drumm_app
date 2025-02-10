
import 'dart:math';

import 'package:agora_token_service/agora_token_service.dart';

class DrummConstants {

  static final String DRUMM_LOGO = "images/logo_dark.png";


  static const String appId = "0608d9da67a9458db263b255c8f30778";
  static String token =
      "007eJxTYDi2XDj2UGSig8f0DawrP32q/z7PTbVP3LeBb22bvmmZ9n4FBgMzA4sUy5REM/NESxNTi5QkIzPjJCNT02SLNGMDc3OLZ+GLkxsCGRk2OLxjYIRCEJ+boSA/Pyc5IzEvLzWHgQEA8RwhmQ==";

  static String customerKey = "42cc54f232f64ed0beb67911d7bcb863";
  static String customerSecret = "2fd744848afa4adebd6c64ac56c8cce9";

  static String generateAgoraToken(String uid, String channelName, {RtcRole ? role}){

    Random random = new Random();
    int randomNumber = random.nextInt(1000000001) + 1;
    // Current timestamp
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Expiry timestamp
    final int privilegeExpiredTs = currentTimestamp + 3600;
    return token = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: "d0a390bebb284783833a0f4f46203a4b",
      channelName: channelName,
      uid: uid,
      role: role??RtcRole.publisher,
      expireTimestamp: privilegeExpiredTs,
    );
  }
}