import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';


class ConversationService{

  ConversationService();

  @override
  Future<void> createConversation(ConversationEntity conversation) async {
    // You can use conversationId as the document id or let Firestore auto-generate one.
    final docRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversation.conversationId ?? FirebaseFirestore.instance.collection('conversations').doc().id);

    final data = {
      'conversationId': conversation.conversationId,
      'title': conversation.title,
      'meta': conversation.meta,
      'category': conversation.category,
      'country': conversation.country,
      'description': conversation.description,
      'url': conversation.url,
      'imageUrl': conversation.imageUrl,
      'publishedAt': conversation.publishedAt,
      'boostamp': conversation.boostamp,
      'question': conversation.question,
      'summary': conversation.summary,
      'content': conversation.content,
      'clusterId': conversation.clusterId,
      'similarId': conversation.similarId,
      'jamId': conversation.jamId,
      'source': conversation.source,
      'dump': conversation.dump,
      'liked': conversation.liked,
      'likes': conversation.likes,
      'reads': conversation.reads,
      'boosts': conversation.boosts,
      'uid': conversation.uid,
      'aiVoiceUrl': conversation.aiVoiceUrl,
      'embedding': conversation.embedding,
      'relatedImageUrls': conversation.relatedImageUrls,
      'lastActive': conversation.lastActive,
      'startedBy': conversation.startedBy,
    };

    await docRef.set(data);
  }

  @override
  Future<List<ConversationEntity>> getConversations() async {

    final threshold = Timestamp.fromDate(DateTime.now().subtract(const Duration(seconds: 30)));


    final querySnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .where('lastActive', isGreaterThan: threshold)
        .orderBy('lastActive', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ConversationEntity(
        conversationId: data['conversationId'] as String?,
        title: data['title'] as String?,
        meta: data['meta'] as String?,
        category: data['category'] as String?,
        country: data['country'] as String?,
        description: data['description'] as String?,
        url: data['url'] as String?,
        imageUrl: data['imageUrl'] as String?,
        publishedAt: data['publishedAt'] as Timestamp?,
        boostamp: data['boostamp'] as Timestamp?,
        question: data['question'] as String?,
        summary: data['summary'] as String?,
        content: data['content'] as String?,
        clusterId: data['clusterId'] as String?,
        similarId: data['similarId'] as String?,
        jamId: data['jamId'] as String?,
        source: data['source'] as String?,
        dump: data['dump'] as String?,
        liked: data['liked'] as bool?,
        likes: data['likes'] as int?,
        reads: data['reads'] as int?,
        boosts: data['boosts'] as int?,
        uid: data['uid'] as String?,
        aiVoiceUrl: data['aiVoiceUrl'] as String?,
        embedding: data['embedding'], // Convert if needed.
        relatedImageUrls: data['relatedImageUrls'] as List<dynamic>?,
        lastActive: data['lastActive'] as Timestamp?,
        startedBy: data['startedBy'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> updateLastActive(String conversationId, Timestamp lastActive) async {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .update({'lastActive': lastActive});
  }

}
