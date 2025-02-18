import 'dart:convert';

import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/helper/access_firebase_token.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<void> sendNotificationToTopic({
    required ConversationEntity conversation,
    required DrummerEntity drummer,
  }) async {

    try {
      final url = Uri.https(
        'fcm.googleapis.com',
        '/v1/projects/drummapp/messages:send',
      );

      // Determine the notification topic.
      // Here we assume that if jamId is null the conversation is a broadcast.
      final bool isBroadcast = conversation.conversationId == null;
      final topic = isBroadcast ? "creator" : conversation.conversationId!;

      // Fetch the access token for FCM.
      final accessTokenGetter = AccessTokenFirebase();
      final String authToken = await accessTokenGetter.getAccessToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Build the notification title and body.
      final subtitle = isBroadcast
          ? "Welcome ${drummer.username} to Drumm"
          : "${drummer.username} is drumming...";

      final notificationBody = conversation.question != null
          ? "${conversation.question}\n\n${conversation.title}"
          : conversation.title;

      // Prepare conversation data by removing lastActive (workaround).
      final conversationMap =
      _conversationToJsonWithoutLastActive(conversation);

      final body = jsonEncode({
        "message": {
          "topic": "broadcast",
          "notification": {
            "body": notificationBody,
            "title": subtitle,
            "image": conversation.imageUrl,
          },
          "data": {
            "conversation": jsonEncode(conversationMap),
            "drummerID": drummer.uid,
          },
          "android": {
            "priority": "high",
            "notification": {
              "sound": "conga_drumm.caf"
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "conga_drumm.caf"
              }
            },
            "headers": {
              "apns-priority": "10"
            }
          }
        }
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        print("Notification Sending error: ${response.body}");
        throw Exception('Failed to send topic notification ${response.statusCode}');
      }
    } catch (e) {
      // You can log or further handle the error here.
      throw Exception("Error sending notification: $e");
    }


  }
  /// Helper method to convert a ConversationEntity into a JSON map while excluding the [lastActive] field.
  Map<String, dynamic> _conversationToJsonWithoutLastActive(ConversationEntity conversation) {
    return {
      'conversationId': conversation.conversationId,
      'title': conversation.title,
      'meta': conversation.meta,
      'category': conversation.category,
      'country': conversation.country,
      'description': conversation.description,
      'url': conversation.url,
      'imageUrl': conversation.imageUrl,
      'publishedAt': conversation.publishedAt?.toDate().toIso8601String(),
      'boostamp': conversation.boostamp?.toDate().toIso8601String(),
      'question': conversation.question,
      'summary': conversation.summary,
      'content': conversation.content,
      'clusterId': conversation.clusterId,
      'similarId': conversation.similarId,
      'jamId': conversation.jamId,
      'source': conversation.source,
      'dump': conversation.dump,
      'liked': conversation.liked,
      'likes': conversation.likes,
      //'reads': conversation.reads,
      //'boosts': conversation.boosts,
      'uid': conversation.uid,
      //'aiVoiceUrl': conversation.aiVoiceUrl,
      //'embedding': conversation.embedding.toString(),
      'relatedImageUrls': conversation.relatedImageUrls,
      // Exclude lastActive, but include the remaining fields:
      'startedBy': conversation.startedBy,
      'pinned': conversation.pinned,
      'pinnedAt': conversation.pinnedAt?.toDate().toIso8601String(),
    };
  }
}
