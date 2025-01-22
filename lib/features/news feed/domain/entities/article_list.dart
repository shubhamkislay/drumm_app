import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:equatable/equatable.dart';

class ArticleListEntity extends Equatable{
  final List<ArticleEntity> ? articleList;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  const ArticleListEntity({this.articleList,this.lastDocument});

  @override
  List<Object?> get props => [lastDocument];

}