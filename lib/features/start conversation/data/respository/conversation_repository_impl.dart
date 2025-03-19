import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/start%20conversation/data/data_sources/conversation_service.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationService conversationService;

  ConversationRepositoryImpl({required this.conversationService});

  @override
  Future<void> createConversation(ConversationEntity conversation) async {
    return conversationService.createConversation(conversation);
  }

  @override
  Future<List<ConversationEntity>> getConversations() {
    return conversationService.getConversations();
  }

  @override
  Future<void> updateLastActive(String conversationId, Timestamp lastActive) {
    return conversationService.updateLastActive(conversationId, lastActive);
  }

  @override
  Future<List<ConversationEntity>> getPinnedConversations(Timestamp from,bool onlyCurrentUser) {
    return conversationService.getPinnedConversations(from,onlyCurrentUser);
  }

  @override
  Future<DataState<bool>> unpinConversation(String conversationId) {
    return conversationService.unpinConversation(conversationId);
  }
}
