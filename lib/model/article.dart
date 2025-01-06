import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
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
  int? likes = 0;
  int? reads = 0;
  int? boosts = 0;
  String? uid;
  String? aiVoiceUrl;
  VectorValue? embedding;
  List<dynamic>? relatedImageUrls;



  Article(
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

  Article.fromJson(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    if (data != null) {
      reads = data['reads'];
      meta = data['meta'];
      liked = data['liked'];
      likes = data['likes'];
      boostamp = data['boostamp'];
      boosts = data['boosts'];
      summary = data['summary'];
      source = data['source'];
      similarId = data['similarId'];
      clusterId = data['clusterId'];
      dump = data['dump'];
      relatedImageUrls = data['relatedImageUrls'];
      category = data['category'];
      articleId = data['articleId'];
      question = data['question'];
      country = data['country'];
      title = data['title'];
      jamId = data['jamId'];
      description = data['description'];
      url = data['url'];
      imageUrl = data['imageUrl'];
      publishedAt = data['publishedAt'];
      content = data['content'];
      uid = data['uid'];
      embedding = data['embedding'] is VectorValue
          ? data['embedding'] as VectorValue // Use the existing VectorValue
          : null; // Correctly parse the VectorValue
      aiVoiceUrl = data['aiVoiceUrl'];
    }
  }


  Article.fromSnapshot(snapshot) {
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
    country = snapshot['country'];
    title = snapshot['title'];
    description = snapshot['description'];
    relatedImageUrls = snapshot['relatedImageUrls'];
    embedding = snapshot['embedding'];
    url = snapshot['url'];
    imageUrl = snapshot['imageUrl'];
    publishedAt = Timestamp.fromMillisecondsSinceEpoch(snapshot['publishedAt']);
    content = snapshot['content'];
    boostamp = Timestamp.fromMillisecondsSinceEpoch(snapshot['boostamp']??0);
    boosts = snapshot['boosts'];
    uid = snapshot['uid'];
    aiVoiceUrl = snapshot['aiVoiceUrl'];
  }

  Article.fromCloudFunction(snapshot) {
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
    boostamp = Timestamp.fromMillisecondsSinceEpoch(snapshot['boostamp']??0);
    boosts = 0;//snapshot['boosts'];
    uid = snapshot['uid'];
    aiVoiceUrl = snapshot['aiVoiceUrl'];
  }

  Article copyWith({String? summary}) {
    return Article(
      reads: this.reads,
      meta: this.meta,
      url: this.url,
      source: this.source,
      summary: summary ?? this.summary,
      title: this.title,
      dump: this.dump,
      category: this.category,
      country: this.country,
      question: this.question,
      description: this.description,
      imageUrl: this.imageUrl,
      publishedAt: this.publishedAt,
      similarId: this.similarId,
      clusterId: this.clusterId,
      boostamp: this.boostamp,
      boosts: this.boosts,
      articleId: this.articleId,
      relatedImageUrls: this.relatedImageUrls,
      jamId: this.jamId,
      embedding: this.embedding,
      content: this.content,
      aiVoiceUrl: this.aiVoiceUrl,
      liked: this.liked,
      likes: this.likes,
      uid: this.uid,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reads'] = this.reads;
    data['category'] = this.category;
    data['source'] = this.source;
    data['dump'] = this.dump;
    data['country'] = this.country;
    data['title'] = this.title;
    data['similarId'] = this.similarId;
    data['clusterId'] = this.clusterId;
    data['meta'] = this.meta;
    data['relatedImageUrls'] = this.relatedImageUrls;
    data['description'] = this.description;
    data['url'] = this.url;
    data['imageUrl'] = this.imageUrl;
    data['publishedAt'] = this.publishedAt;
    data['content'] = this.content;
    data['boostamp'] = this.boostamp;
    data['boosts'] = this.boosts;
    data['question'] = this.question;
    data['articleId'] = this.articleId;
    data['jamId'] = this.jamId;
    data['summary'] = this.summary;
    data['likes'] = this.likes;
    data['uid'] = this.uid;
    data['aiVoiceUrl'] = this.aiVoiceUrl;
    return data;
  }
}
