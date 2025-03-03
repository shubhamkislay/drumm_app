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

      final accessTokenGetter = AccessTokenFirebase();
      final String authToken = await accessTokenGetter.getAccessToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Build the notification title and body.
      final subtitle = "${drummer.username} started a conversation";

      final notificationBody = conversation.question != null
          ? "${conversation.question}\n\n${conversation.title}"
          : conversation.title;

      // Prepare conversation data by removing lastActive (workaround).
      final conversationMap =
      _conversationToJsonWithoutLastActive(conversation);

      final body = jsonEncode({
        "message": {
          "topic": conversation.bandId,
          "notification": {
            "body": notificationBody,
            "title": subtitle,
            "image": conversation.imageUrl,
          },
          "data": {
            "type": "conversation",
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
                "contentAvailable": true,
                "sound": "conga_drumm.caf"
              }
            },
            "headers": {
              "apns-priority": "5"
            }
          }
        }
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        print("Notification Sending error: ${response.body}");
        throw Exception('Failed to send topic notification ${response.statusCode}');
      }else{
        print("Sent Notification successfully to ${conversation.bandId}");
      }
    } catch (e) {
      // You can log or further handle the error here.
      throw Exception("Error sending notification: $e");
    }


  }

  Future<void> sendNotificationToUser({
    required ConversationEntity conversation,
    required DrummerEntity drummer,
  }) async {

    try {
      final url = Uri.https(
        'fcm.googleapis.com',
        '/v1/projects/drummapp/messages:send',
      );

      final accessTokenGetter = AccessTokenFirebase();
      final String authToken = await accessTokenGetter.getAccessToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Build the notification title and body.
      final subtitle = "${drummer.username} joined your pinned conversation";

      final notificationBody = conversation.question != null
          ? "${conversation.question}\n\n${conversation.title}"
          : conversation.title;

      // Prepare conversation data by removing lastActive (workaround).
      final conversationMap =
      _conversationToJsonWithoutLastActive(conversation);

      final body = jsonEncode({
        "message": {
          "topic": conversation.startedBy,
          "notification": {
            "body": notificationBody,
            "title": subtitle,
            "image": conversation.imageUrl,
          },
          "data": {
            "type": "conversation",
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
                "contentAvailable": true,
                "sound": "conga_drumm.caf"
              }
            },
            "headers": {
              "apns-priority": "5"
            }
          }
        }
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        print("Notification Sending error: ${response.body}");
        throw Exception('Failed to send topic notification ${response.statusCode}');
      }else{
        print("Sent Notification successfully to ${conversation.bandId}");
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
      'articleId': conversation.articleId,
      'bandId': conversation.bandId,
      'title': conversation.title,
      'meta': conversation.meta,
      'category': conversation.category,
      'country': conversation.country,
      'description': conversation.description,
      'url': conversation.url,
      'imageUrl': conversation.imageUrl,
      'publishedAt': conversation.publishedAt?.millisecondsSinceEpoch,
      'boostamp': conversation.boostamp?.millisecondsSinceEpoch,
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
      'pinnedAt': conversation.pinnedAt?.millisecondsSinceEpoch,
    };
  }
}
