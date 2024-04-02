import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? query;
  String? uid;
  String? qid;
  String? hook;
  String? departmentName;
  String? designation;
  List<String>? tags;
  Timestamp? createdTime;

  Question();

  Map<String, dynamic> toJson() => {
    'query': query,
    'departmentName':departmentName,
    'designation':designation,
    'uid': uid,
    'qid': qid,
    'hook': hook,
    'tags': tags,
    'createdTime': createdTime
  };

  Question.fromSnapshot(snapshot)
      : query = snapshot.data()['query'],
        uid = snapshot.data()['uid'],
        qid = snapshot.data()['qid'],
        departmentName = snapshot.data()['departmentName'],
        designation = snapshot.data()['designation'],
        hook = snapshot.data()['hook'],
  //tags = snapshot.data()['tags'],
        createdTime =  snapshot.data()['createdTime'];
}
