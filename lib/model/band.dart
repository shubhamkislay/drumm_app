import 'package:cloud_firestore/cloud_firestore.dart';

class Band {
  String? foundedBy;
  String? bandId;
  String? count;
  String? description;
  Timestamp? creationTime;
  String? name;
  String? url;
  String? visibility;
  List<dynamic>? hooks;

  Band({
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

  Band.fromJsonObject(Map<Object?, Object?> json)
      : foundedBy = json['foundedBy'].toString(),
        bandId = json['bandId'].toString(),
        count = json['count'].toString(),
        creationTime = Timestamp.now(),
        name = json['name'].toString(),
        url = json['url'].toString(),
        visibility = json['visibility'].toString(),
        description = json['description'].toString(),
        hooks = convertObjectToList(json['hooks']);

  static List<dynamic> convertObjectToList(Object? object) {
    if (object == null) {
      return []; // return an empty list if the object is null
    } else if (object is List<dynamic>) {
      return object; // if it's already a List<dynamic>, return as is
    } else {
      throw FormatException('Object cannot be converted to List<dynamic>');
    }
  }

  Band.fromSnapshot(snapshot)
      : foundedBy = snapshot.data()['foundedBy'],
        bandId = snapshot.data()['bandId'],
        count = snapshot.data()['count'].toString(),
        creationTime = snapshot.data()['creationTime'],
        name = snapshot.data()['name'],
        url = snapshot.data()['url'],
        visibility = snapshot.data()['visibility'],
        description = snapshot.data()['description'],
        hooks = snapshot.data()['hooks'];

  Band.fromAlgoliaSnapshot(snapshot)
      : foundedBy = snapshot['foundedBy'],
        bandId = snapshot['bandId'],
        count = snapshot['count'].toString(),
        //creationTime = Timestamp.fromMillisecondsSinceEpoch(snapshot['creationTime']),
        name = snapshot['name'],
        url = snapshot['url'],
        visibility = snapshot['visibility'],
        hooks = snapshot['hooks'],
        description = snapshot['description'];
}
