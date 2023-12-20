import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  String? title;
  String? category;
  String? country;
  String? description;
  String? url;
  String? imageUrl;
  Timestamp? publishedAt;
  String? question;
  String? summary;
  String? content;
  String? articleId;
  String? jamId;
  String? source;
  String? dump;
  bool? liked;
  int? likes = 0;
  int? reads = 0;
  String? uid;
  String? aiVoiceUrl;


  Article(
      {this.summary,
        this.liked,
        this.likes,
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
        this.uid,
        this.aiVoiceUrl,
      this.content});

  Article.fromJson(snapshot) {
    reads = snapshot.data()['reads'];
    liked = snapshot.data()['liked'];
    likes = snapshot.data()['likes'];
    summary = snapshot.data()['summary'];
    source = snapshot.data()['source'];
    dump = snapshot.data()['dump'];
    category = snapshot.data()['category'];
    articleId = snapshot.data()['articleId'];
    question = snapshot.data()['question'];
    country = snapshot.data()['country'];
    title = snapshot.data()['title'];
    jamId = snapshot.data()['jamId'];
    description = snapshot.data()['description'];
    url = snapshot.data()['url'];
    imageUrl = snapshot.data()['imageUrl'];
    publishedAt = snapshot.data()['publishedAt'];
    content = snapshot.data()['content'];
    uid = snapshot.data()['uid'];
    aiVoiceUrl = snapshot.data()['aiVoiceUrl'];
  }

  Article.fromSnapshot(snapshot) {
    reads = snapshot['reads'];
    liked = snapshot['liked'];
    likes = snapshot['likes'];
    summary = snapshot['summary'];
    source = snapshot['source'];
    dump = snapshot['dump'];
    category = snapshot['category'];
    question = snapshot['question'];
    articleId = snapshot['articleId'];
    jamId = snapshot['jamId'];
    country = snapshot['country'];
    title = snapshot['title'];
    description = snapshot['description'];
    url = snapshot['url'];
    imageUrl = snapshot['imageUrl'];
    publishedAt = Timestamp.fromMillisecondsSinceEpoch(snapshot['publishedAt']);
    content = snapshot['content'];
    uid = snapshot['uid'];
    aiVoiceUrl = snapshot['aiVoiceUrl'];
  }

  Article copyWith({String? summary}) {
    return Article(
      reads: this.reads,
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
      articleId: this.articleId,
      jamId: this.jamId,
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
    data['description'] = this.description;
    data['url'] = this.url;
    data['imageUrl'] = this.imageUrl;
    data['publishedAt'] = this.publishedAt;
    data['content'] = this.content;
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
