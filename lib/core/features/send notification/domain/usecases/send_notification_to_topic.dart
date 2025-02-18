import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/send%20notification/domain/repository/notification_repository.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

class SendNotificationToTopicUseCase {
  final NotificationRepository repository;

  SendNotificationToTopicUseCase(this.repository);

  Future<void> call({
    required ConversationEntity conversation,
    required DrummerEntity drummer,
  }) async {
    return repository.sendNotificationToTopic(
      conversation: conversation,
      drummer: drummer,
    );
  }
}
