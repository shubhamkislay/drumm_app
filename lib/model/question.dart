class Question {
  String? query;
  String? uid;
  String? qid;
  String? category;
  List<String>? tags;
  DateTime? createdTime;

  Question();

  Map<String, dynamic> toJson() => {
    'query': query,
    'uid': uid,
    'qid': qid,
    'category': category,
    'tags': tags,
    'createdTime': createdTime
  };

  Question.fromSnapshot(snapshot)
      : query = snapshot.data()['query'],
        uid = snapshot.data()['uid'],
        qid = snapshot.data()['qid'],
        category = snapshot.data()['category'],
  //tags = snapshot.data()['tags'],
        createdTime = snapshot.data()['createdTime'].toDate();
}
