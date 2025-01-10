import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Jam {
  String? startedBy;
  String? jamId;
  String? articleId;
  String? bandId;
  int? count;
  String? title;
  bool? broadcast = false;
  String? creationTime;
  String? imageUrl;
  String? question;
  Timestamp? lastActive;
  VectorValue? embedding;
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
    'question': question?.trim(),
    'membersID': membersID,
    'broadcast': broadcast,
    'imageUrl': imageUrl,
    'embedding': embedding?.toArray(),
    'lastActive': lastActive,
  };

  Jam.fromJson(Map<String, dynamic> json)
      : startedBy = json['startedBy']?.toString(),
        bandId = json['bandId'],
        broadcast = json['broadcast'],
        count = json['count'],
        question = json['question'].toString().trim(),
        embedding = json['embedding'] is List<dynamic>
            ? VectorValue(List<double>.from(json['embedding'] as List<dynamic>))
            : null,
        creationTime = json['creationTime']?.toString(),
        jamId = json['jamId'],
        articleId = json['articleId'],
        title = json['title'],
        imageUrl = json['imageUrl'],
        lastActive = json['lastActive'],
        membersID = json['membersID'] != null ? List<dynamic>.from(json['membersID']) : null;

  Jam.fromJsonObject(Map<Object?, Object?> json)
      : startedBy = json['startedBy']?.toString(),
        bandId = json['bandId']?.toString(),
        broadcast = json['broadcast']?.toString()?.toLowerCase() == 'true',
        count = int.tryParse(json['count']?.toString() ?? '0'),
        question = json['question']?.toString().trim(),
        creationTime = json['creationTime']?.toString(),
        embedding = json['embedding'] is List<dynamic>
            ? VectorValue(List<double>.from(json['embedding'] as List<dynamic>))
            : null, // Parse List<double> back into VectorValue
        jamId = json['jamId']?.toString(),
        articleId = json['articleId']?.toString(),
        title = json['title']?.toString(),
        imageUrl = json['imageUrl']?.toString(),
        lastActive = Timestamp.now();

  factory Jam.fromRealtimeSnapshot(DataSnapshot snapshot) {
    Jam jam = Jam.fromDataSnapshot(snapshot.value as Map<dynamic, dynamic>);
    return jam;
  }

  Jam.fromSnapshot(snapshot)
      : startedBy = snapshot.data()['startedBy'],
        bandId = snapshot.data()['bandId'],
        count = snapshot.data()['count'],
        question = snapshot.data()['question'].toString(),
        creationTime = snapshot.data()['creationTime']?.toString(),
        title = snapshot.data()['title'],
        broadcast = snapshot.data()['broadcast'],
        membersID = snapshot.data()['membersID'],
        articleId = snapshot.data()['articleId'],
        imageUrl = snapshot.data()['imageUrl'],
        embedding = snapshot.data()?['embedding'] is List<dynamic>
            ? VectorValue(List<double>.from(snapshot.data()?['embedding'] as List<dynamic>))
            : null, // Parse List<double> back into VectorValue
        lastActive = snapshot.data()['lastActive'],
        jamId = snapshot.data()['jamId'];

  Jam.fromDataSnapshot(snapshot)
      : startedBy = snapshot['startedBy'],
        bandId = snapshot['bandId'],
        count = snapshot['count'],
        question = snapshot['question'].toString().trim(),
        creationTime = snapshot['creationTime']?.toString(),
        title = snapshot['title'],
        broadcast = snapshot['broadcast'],
        membersID = snapshot['membersID'],
        embedding = snapshot['embedding'] is List<dynamic>
            ? VectorValue(List<double>.from(snapshot['embedding'] as List<dynamic>))
            : null, // Parse List<double> back into VectorValue
        imageUrl = snapshot['imageUrl'],
        lastActive = snapshot['lastActive'],
        jamId = snapshot['jamId'];

  Jam.fromDocListenSnapshot(snapshot)
      : startedBy = snapshot.get('startedBy'),
        bandId = snapshot.get('bandId'),
        count = snapshot.get('count'),
        question = snapshot.get('question').toString().trim(),
        creationTime = snapshot.get('creationTime')?.toString(),
        title = snapshot.get('title'),
        broadcast = snapshot.get('broadcast'),
        membersID = snapshot.get('membersID'),
        embedding = snapshot.get('embedding') is List<dynamic>
            ? VectorValue(List<double>.from(snapshot.get('embedding') as List<dynamic>))
            : null, // Parse List<double> back into VectorValue
        imageUrl = snapshot.get('imageUrl'),
        lastActive = snapshot.get('lastActive'),
        jamId = snapshot.get('jamId');
}
