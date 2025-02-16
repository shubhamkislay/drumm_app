import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class CreateConversationUseCase {
  final ConversationRepository repository;

  CreateConversationUseCase(this.repository);

  Future<void> call(ConversationEntity conversation) async {
    return repository.createConversation(conversation);
  }
}
