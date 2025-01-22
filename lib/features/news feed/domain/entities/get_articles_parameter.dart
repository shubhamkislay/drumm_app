import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GetArticlesParams extends Equatable{
  final List<String> ? category;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  const GetArticlesParams({this.category, this.lastDocument});

  @override
  List<Object?> get props => [category,lastDocument];
}