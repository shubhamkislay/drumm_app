import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BandEntity extends Equatable{
  final String? foundedBy;
  final String? bandId;
  final String? count;
  final String? description;
  final Timestamp? creationTime;
  final String? name;
  final String? url;
  final String? visibility;
  final List<dynamic>? hooks;

  const BandEntity({
    this.foundedBy,
    this.bandId,
    this.count,
    this.description,
    this.creationTime,
    this.name,
    this.url,
    this.visibility,
    this.hooks,
  });

  @override
  List<Object?> get props => [bandId,url,name];

}