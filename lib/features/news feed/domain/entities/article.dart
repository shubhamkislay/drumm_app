import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
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
  final String? articleId;
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



  const ArticleEntity(
      {this.summary,
        this.liked,
        this.likes,
        this.boostamp,
        this.boosts,
        this.clusterId,
        this.similarId,
        this.meta,
        this.category,
        this.source,
        this.country,
        this.question,
        this.title,
        this.description,
        this.url,
        this.imageUrl,
        this.dump,
        this.publishedAt,
        this.articleId,
        this.jamId,
        this.reads,
        this.relatedImageUrls,
        this.uid,
        this.embedding,
        this.aiVoiceUrl,
        this.content});

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'liked': liked,
    'likes': likes,
    'boostamp': boostamp?.toDate().toIso8601String(), // Converted
    'boosts': boosts,
    'clusterId': clusterId,
    'similarId': similarId,
    'meta': meta,
    'category': category,
    'source': source,
    'country': country,
    'title': title,
    'description': description,
    'url': url,
    'imageUrl': imageUrl,
    'dump': dump,
    'question': question,
    'publishedAt': publishedAt?.toDate().toIso8601String(), // Converted
    'articleId': articleId,
    'jamId': jamId,
    'reads': reads,
    'relatedImageUrls': relatedImageUrls,
    'uid': uid,
    'embedding': embedding, // Verify this is serializable or convert it as needed.
    'aiVoiceUrl': aiVoiceUrl,
    'content': content,
  };



  @override
  List<Object?> get props => [uid];
}
