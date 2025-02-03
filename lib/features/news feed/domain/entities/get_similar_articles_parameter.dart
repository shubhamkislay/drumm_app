import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:equatable/equatable.dart';

class GetSimilarArticlesParams extends Equatable{
  final VectorValue ? embedding;
  final ArticleEntity ? article;

  const GetSimilarArticlesParams({this.embedding, this.article});

  @override
  List<Object?> get props => [embedding,article];
}