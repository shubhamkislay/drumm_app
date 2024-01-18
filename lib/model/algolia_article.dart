import 'package:cloud_firestore/cloud_firestore.dart';

import 'article.dart';

class AlgoliaArticles {
  String? queryID;
  List<Article>? articles;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  DocumentSnapshot<Map<String, dynamic>>? _startDocument;

  AlgoliaArticles({this.queryID,
    this.articles});

  void setLastDocument( DocumentSnapshot<Map<String, dynamic>>? setDocument){
    _lastDocument = setDocument;
  }

  DocumentSnapshot<Map<String, dynamic>>? getLastDocument(){
    return _lastDocument;
  }

  void setStartDocument( DocumentSnapshot<Map<String, dynamic>>? setDocument){
    _startDocument = setDocument;
  }

  DocumentSnapshot<Map<String, dynamic>>? getStartDocument(){
    return _startDocument;
  }
}