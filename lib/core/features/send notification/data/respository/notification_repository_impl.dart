import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/send%20notification/data/data_sources/notification_service.dart';
import 'package:drumm_app/core/features/send%20notification/domain/repository/notification_repository.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationService notificationService;

  NotificationRepositoryImpl(this.notificationService);

  @override
  Future<void> sendNotificationToTopic({
    required ConversationEntity conversation,
    required DrummerEntity drummer,
  }) async {
    notificationService.sendNotificationToTopic(
        conversation: conversation, drummer: drummer);
  }
}
