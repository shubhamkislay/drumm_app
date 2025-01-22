import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';

class BandModel extends BandEntity{
  String? foundedBy;
  String? bandId;
  String? count;
  String? description;
  Timestamp? creationTime;
  String? name;
  String? url;
  String? visibility;
  List<dynamic>? hooks;

  BandModel({
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

  Map<String, dynamic> toJson() => {
    'foundedBy': foundedBy,
    'bandId': bandId,
    'count': count,
    'creationTime': creationTime,
    'name': name,
    'url': url,
    'visibility': visibility,
    'description': description,
    'hooks': hooks,
  };

  factory BandModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return BandModel(
        foundedBy:snapshot.data()!['foundedBy'],
      bandId:snapshot.data()!['bandId'],
      count:snapshot.data()!['count'],
      creationTime:snapshot.data()!['creationTime'],
      name:snapshot.data()!['name'],
      url:snapshot.data()!['url'],
      visibility:snapshot.data()!['visibility'],
      description:snapshot.data()!['description'],
      hooks:snapshot.data()!['hooks'],
    );
  }


}