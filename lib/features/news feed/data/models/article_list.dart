import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article_list.dart';

class ArticleListModel extends ArticleListEntity{
  List<ArticleModel> ? articleList;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  ArticleListModel({this.articleList,this.lastDocument});

}