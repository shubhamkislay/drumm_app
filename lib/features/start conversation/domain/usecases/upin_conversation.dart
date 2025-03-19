import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class UnpinConversationUseCase {
  final ConversationRepository repository;

  UnpinConversationUseCase(this.repository);

  Future<DataState<bool>> call({required String conversationId}) async {
    return repository.unpinConversation(conversationId);
  }
}
