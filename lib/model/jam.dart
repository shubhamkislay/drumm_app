import 'package:firebase_database/firebase_database.dart';

class Jam {
  String? startedBy;
  String? jamId;
  String? articleId;
  String? bandId;
  int? count;
  String? title;
  bool? broadcast=false;
  String? creationTime;
  String? imageUrl;
  List<dynamic>? membersID;

  Jam();

  Map<String, dynamic> toJson() => {
    'startedBy': startedBy,
    'bandId': bandId,
    'count': count,
    'creationTime': creationTime,
    'jamId': jamId,
    'articleId': articleId,
    'title': title,
    'membersID': membersID,
    'broadcast': broadcast,
    'imageUrl':imageUrl,
  };

  Jam.fromJson(Map<String, dynamic> json)
      : startedBy = json['startedBy'].toString(),
        bandId = json['bandId'],
        broadcast = json['broadcast'],
        count = json['count'],
        creationTime = json['creationTime'].toString(),
        jamId = json['jamId'],
        articleId = json['articleId'],
        title = json['title'],
        imageUrl = json['imageUrl'],
        membersID = List<dynamic>.from(json['membersID']);

  factory Jam.fromRealtimeSnapshot(DataSnapshot snapshot) {
    Jam jam = Jam.fromDataSnapshot(snapshot.value);
    return jam;
  }

  Jam.fromSnapshot(snapshot)
      : startedBy = snapshot.data()['startedBy'],
        bandId = snapshot.data()['bandId'],
        count = snapshot.data()['count'],
        creationTime = snapshot.data()['creationTime'].toString(),
        title = snapshot.data()['title'],
        broadcast = snapshot.data()['broadcast'],
        membersID = snapshot.data()['membersID'],
        articleId = snapshot.data()['articleId'],
        imageUrl = snapshot.data()['imageUrl'],
        jamId = snapshot.data()['jamId'];

  Jam.fromDataSnapshot(snapshot)
      : startedBy = snapshot['startedBy'],
        bandId = snapshot['bandId'],
        count = snapshot['count'],
        creationTime = snapshot['creationTime'].toString(),
        title = snapshot['title'],
        broadcast = snapshot['broadcast'],
        membersID = snapshot['membersID'],
        imageUrl = snapshot['imageUrl'],
        jamId = snapshot['jamId'];

  Jam.fromDocListenSnapshot(snapshot)
      : startedBy = snapshot.get('startedBy'),
        bandId = snapshot.get('bandId'),
        count = snapshot.get('count'),
        creationTime = snapshot.get('creationTime').toString(),
        title = snapshot.get('title'),
        broadcast = snapshot.get('broadcast'),
        membersID = snapshot.get('membersID'),
        imageUrl = snapshot.get('imageUrl'),
        jamId = snapshot.get('jamId');
}
