import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

abstract class ConversationRepository {
  Future<void> createConversation(ConversationEntity conversation);
  Future<List<ConversationEntity>> getConversations();
  Future<void> updateLastActive(String conversationId, Timestamp lastActive);
}
