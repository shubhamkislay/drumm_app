import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class GetConversationsUseCase {
  final ConversationRepository repository;

  GetConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call() async {
    return repository.getConversations();
  }
}
