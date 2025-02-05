import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserActivityService {
  Future<void> recordUserActivity(UserActivityEntity userActivity) async {
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final String newInteractionId = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc()
        .id;
    final DocumentReference userLikeRef = FirebaseFirestore.instance
        .collection("userActivity")
        .doc(currentUserID)
        .collection("interactions")
        .doc(newInteractionId);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime currentTime = DateTime.now();
      batch.set(
        userLikeRef,
        {
          'timestamp': Timestamp.fromDate(currentTime),
          'articleId': userActivity.articleId,
          'type': userActivity.type,
          'userId': currentUserID,
          'interactionId': newInteractionId,
          'weight': userActivity.weight,
          'embedding': userActivity.embedding,
        },
      );

      await batch.commit();
    } catch (error) {
      if(kDebugMode){
        print("Error while recording user activity. ${error.toString()}");
      }
    }
  }
}
