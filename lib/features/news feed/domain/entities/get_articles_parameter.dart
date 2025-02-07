import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:equatable/equatable.dart';

class GetArticlesParams extends Equatable{
  final List<String> ? category;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final DrummerEntity ? drummerEntity;

  const GetArticlesParams({this.category, this.lastDocument, this.drummerEntity});

  @override
  List<Object?> get props => [category,lastDocument];
}