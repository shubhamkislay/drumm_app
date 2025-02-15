import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

class ArticleModel extends ArticleEntity {
  String? title;
  String? meta;
  String? category;
  String? country;
  String? description;
  String? url;
  String? imageUrl;
  Timestamp? publishedAt;
  Timestamp? boostamp;
  String? question;
  String? summary;
  String? content;
  String? articleId;
  String? clusterId;
  String? similarId;
  String? jamId;
  String? source;
  String? dump;
  bool? liked;
  int? likes;
  int? reads;
  int? boosts;
  String? uid;
  String? aiVoiceUrl;
  VectorValue? embedding;
  List<dynamic>? relatedImageUrls;

  ArticleModel(
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
        'boostamp': boostamp,
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
        'publishedAt': publishedAt,
        'articleId': articleId,
        'jamId': jamId,
        'reads': reads,
        'relatedImageUrls': relatedImageUrls,
        'uid': uid,
        'embedding': embedding,
        'aiVoiceUrl': aiVoiceUrl,
        'content': content,
      };

  factory ArticleModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return ArticleModel(
      summary: snapshot.data()!['summary'],
      liked: snapshot.data()?['liked'],
      likes: snapshot.data()?['likes'],
      boostamp: snapshot.data()?['boostamp'],
      boosts: snapshot.data()?['boosts'],
      clusterId: snapshot.data()?['clusterId'],
      similarId: snapshot.data()?['similarId'],
      meta: snapshot.data()?['meta'],
      category: snapshot.data()?['category'],
      source: snapshot.data()?['source'],
      country: snapshot.data()?['country'],
      title: snapshot.data()?['title'],
      description: snapshot.data()?['description'],
      url: snapshot.data()?['url'],
      imageUrl: snapshot.data()?['imageUrl'],
      dump: snapshot.data()?['dump'],
      publishedAt: snapshot.data()?['publishedAt'],
      articleId: snapshot.data()?['articleId'],
      jamId: snapshot.data()?['jamId'],
      question: snapshot.data()?['question'],
      reads: snapshot.data()?['reads'],
      relatedImageUrls: snapshot.data()?['relatedImageUrls'],
      uid: snapshot.data()?['uid'],
      embedding: snapshot.data()?['embedding'],
      aiVoiceUrl: snapshot.data()?['aiVoiceUrl'],
      content: snapshot.data()?['content'],
    );
  }

  ArticleModel.fromCloudFunction(snapshot) {
    reads = snapshot['reads'];
    meta = snapshot['meta'];
    liked = snapshot['liked'];
    likes = snapshot['likes'];
    summary = snapshot['summary'];
    source = snapshot['source'];
    dump = snapshot['dump'];
    category = snapshot['category'];
    question = snapshot['question'];
    articleId = snapshot['articleId'];
    similarId = snapshot['similarId'];
    clusterId = snapshot['clusterId'];
    jamId = snapshot['jamId'];
    relatedImageUrls = snapshot['relatedImageUrls'];
    country = snapshot['country'];
    title = snapshot['title'];
    description = snapshot['description'];
    embedding = VectorValue(snapshot['embedding']['_values'].cast<double>());
    url = snapshot['url'];
    imageUrl = snapshot['imageUrl'];
    publishedAt = Timestamp.fromMillisecondsSinceEpoch(snapshot['publishedAt']);
    content = snapshot['content'];
    boostamp = Timestamp.fromMillisecondsSinceEpoch(snapshot['boostamp'] ?? 0);
    boosts = 0; //snapshot['boosts'];
    uid = snapshot['uid'];
    aiVoiceUrl = snapshot['aiVoiceUrl'];
  }
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'],
      meta: json['meta'],
      category: json['category'],
      country: json['country'],
      description: json['description'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      publishedAt: json['publishedAt'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['publishedAt']) : null,
      boostamp: json['boostamp'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['boostamp']) : null,
      question: json['question'],
      summary: json['summary'],
      content: json['content'],
      articleId: json['articleId'],
      clusterId: json['clusterId'],
      similarId: json['similarId'],
      jamId: json['jamId'],
      source: json['source'],
      dump: json['dump'],
      liked: json['liked'],
      likes: json['likes'],
      reads: json['reads'],
      boosts: json['boosts'],
      uid: json['uid'],
      aiVoiceUrl: json['aiVoiceUrl'],
      // Assume a proper conversion for embedding and relatedImageUrls.
      embedding: json['embedding._values'] != null ? VectorValue(json['embedding._values'] as List<double>) : null,
      relatedImageUrls: json['relatedImageUrls'],
    );
  }
}
