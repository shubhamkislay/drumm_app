import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

abstract class NotificationRepository {
  Future<void> sendNotificationToTopic({
    required ConversationEntity conversation,
    required DrummerEntity drummer,
  });
}
