import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class UpdateLastActiveUseCase {
  final ConversationRepository repository;

  UpdateLastActiveUseCase(this.repository);

  Future<void> call(String conversationId, Timestamp lastActive) async {
    return repository.updateLastActive(conversationId, lastActive);
  }
}
