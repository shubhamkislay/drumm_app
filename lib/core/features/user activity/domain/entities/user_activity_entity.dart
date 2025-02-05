import 'package:cloud_firestore/cloud_firestore.dart';

class UserActivityEntity {
  final String type;
  final double weight;
  final String articleId;
  final VectorValue embedding;

  const UserActivityEntity({
    required this.type,
    required this.articleId,
    required this.weight,
    required this.embedding,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is UserActivityEntity &&
              other.type == type &&
              other.weight == weight &&
              other.articleId == articleId &&
              other.embedding == embedding);

  @override
  int get hashCode => type.hashCode ^ weight.hashCode ^ embedding.hashCode ^ articleId.hashCode;
}
