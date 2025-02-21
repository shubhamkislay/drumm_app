import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String? conversationId;
  final String? title;
  final String? meta;
  final String? category;
  final String? country;
  final String? description;
  final String? url;
  final String? imageUrl;
  final Timestamp? publishedAt;
  final Timestamp? boostamp;
  final String? question;
  final String? summary;
  final String? content;
  final String? clusterId;
  final String? similarId;
  final String? jamId;
  final String? source;
  final String? dump;
  final bool? liked;
  final int? likes;
  final int? reads;
  final int? boosts;
  final String? uid;
  final String? aiVoiceUrl;
  final VectorValue? embedding;
  final List<dynamic>? relatedImageUrls;

  // Additional fields for Conversation
  final Timestamp? lastActive;
  final String? startedBy; // Firebase current user id

  // New fields for pinning
  final bool? pinned;
  final Timestamp? pinnedAt;

  const ConversationEntity({
    this.conversationId,
    this.title,
    this.meta,
    this.category,
    this.country,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
    this.boostamp,
    this.question,
    this.summary,
    this.content,
    this.clusterId,
    this.similarId,
    this.jamId,
    this.source,
    this.dump,
    this.liked,
    this.likes,
    this.reads,
    this.boosts,
    this.uid,
    this.aiVoiceUrl,
    this.embedding,
    this.relatedImageUrls,
    this.lastActive,
    this.startedBy,
    this.pinned,
    this.pinnedAt,
  });

  /// Converts a JSON map into a ConversationEntity.
  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    try {
      return ConversationEntity(
        conversationId: json['conversationId'] as String?,
        title: json['title'] as String?,
        meta: json['meta'] as String?,
        category: json['category'] as String?,
        country: json['country'] as String?,
        description: json['description'] as String?,
        url: json['url'] as String?,
        imageUrl: json['imageUrl'] as String?,
        publishedAt: json['publishedAt'] != null
            ? Timestamp.fromMillisecondsSinceEpoch(json['publishedAt'])
            : null,
        // boostamp: json['boostamp'] != null
        //     ? Timestamp.fromMillisecondsSinceEpoch(json['boostamp'])
        //     : null,
        question: json['question'] as String?,
        summary: json['summary'] as String?,
        content: json['content'] as String?,
        clusterId: json['clusterId'] as String?,
        similarId: json['similarId'] as String?,
        jamId: json['jamId'] as String?,
        source: json['source'] as String?,
        dump: json['dump'] as String?,
        liked: json['liked'] as bool?,
        //likes: json['likes'] as int?,
        // reads: json['reads'] as int?,
        // boosts: json['boosts'] as int?,
        uid: json['uid'] as String?,
        // aiVoiceUrl: json['aiVoiceUrl'] as String?,
        // embedding: json['embedding'] != null
        //     ? VectorValue(json['embedding'])
        //     : null,
        relatedImageUrls: json['relatedImageUrls'] as List<dynamic>?,
        // lastActive: json['lastActive'] != null
        //     ? Timestamp.fromMillisecondsSinceEpoch(json['lastActive'])
        //     : null,
        startedBy: json['startedBy'] as String?,
        pinned: json['pinned'] as bool?,
        pinnedAt: json['pinnedAt'] != null
            ? Timestamp.fromMillisecondsSinceEpoch(json['pinnedAt'])
            : null,
      );
    }catch(e){
      print("Error converting from JSON: ${e.toString()}");
      return ConversationEntity();
    }
  }

  @override
  List<Object?> get props => [
    conversationId,
    title,
    meta,
    category,
    country,
    description,
    url,
    imageUrl,
    publishedAt,
    boostamp,
    question,
    summary,
    content,
    clusterId,
    similarId,
    jamId,
    source,
    dump,
    liked,
    likes,
    reads,
    boosts,
    uid,
    aiVoiceUrl,
    embedding,
    relatedImageUrls,
    lastActive,
    startedBy,
    pinned,
    pinnedAt,
  ];
}
