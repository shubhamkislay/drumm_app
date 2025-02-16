import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';


class CreatePinConversationUseCase {
  final ConversationRepository repository;

  CreatePinConversationUseCase(this.repository);

  Future<void> call(ConversationEntity conversation) async {
    // Create a new instance (or use copyWith if available) with the pin fields set.
    final pinnedConversation = ConversationEntity(
      conversationId: conversation.conversationId,
      title: conversation.title,
      meta: conversation.meta,
      category: conversation.category,
      country: conversation.country,
      description: conversation.description,
      url: conversation.url,
      imageUrl: conversation.imageUrl,
      publishedAt: conversation.publishedAt,
      boostamp: conversation.boostamp,
      question: conversation.question,
      summary: conversation.summary,
      content: conversation.content,
      clusterId: conversation.clusterId,
      similarId: conversation.similarId,
      jamId: conversation.jamId,
      source: conversation.source,
      dump: conversation.dump,
      liked: conversation.liked,
      likes: conversation.likes,
      reads: conversation.reads,
      boosts: conversation.boosts,
      uid: conversation.uid,
      aiVoiceUrl: conversation.aiVoiceUrl,
      embedding: conversation.embedding,
      relatedImageUrls: conversation.relatedImageUrls,
      lastActive: conversation.lastActive,
      startedBy: conversation.startedBy,
      // Set new fields for pinning:
      pinned: true,
      pinnedAt: Timestamp.now(),
    );
    await repository.createConversation(pinnedConversation);
  }
}
