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
