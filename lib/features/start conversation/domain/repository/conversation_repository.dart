import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

abstract class ConversationRepository {
  Future<void> createConversation(ConversationEntity conversation);
  Future<List<ConversationEntity>> getConversations();
  Future<DataState<bool>> unpinConversation(String conversationId);
  Future<void> updateLastActive(String conversationId, Timestamp lastActive);

  /// New: Retrieve all conversations that are pinned and whose
  /// pinnedAt timestamp is greater than or equal to [from].
  Future<List<ConversationEntity>> getPinnedConversations(Timestamp from, bool onlyCurrentUser);
}
