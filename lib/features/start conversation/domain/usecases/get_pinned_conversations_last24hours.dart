import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';

class GetPinnedConversationsLast24Hours {
  final ConversationRepository repository;

  GetPinnedConversationsLast24Hours(this.repository);

  Future<List<ConversationEntity>> call({required bool onlyCurrentUser}) async {
    final now = Timestamp.now();
    final threshold = Timestamp.fromDate(now.toDate().subtract(const Duration(hours: 24)));
    return repository.getPinnedConversations(threshold,onlyCurrentUser);
  }
}
