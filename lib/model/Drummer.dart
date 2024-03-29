class Drummer {
  String? token;
  String? uid;
  String? name;
  String? email;
  String? username;
  String? bio;
  String? occupation;
  int? badges = 0;
  String? imageUrl;
  String? jobTitle;
  String? organisation;
  int? followerCount = 0;
  int? rid;
  int? followingCount = 0;
  bool speaking = false;
  bool muted = true;

  Drummer();

  Map<String, dynamic> toJson() => {
        'token': token,
        'name': name,
        'rid': rid,
        'email': email,
        'username': username,
        'bio': bio,
        'badges': badges,
        'uid': uid,
        'occupation': occupation,
        'speaking': speaking,
        'muted': muted,
        'imageUrl': imageUrl,
        'jobTitle': jobTitle,
        'organisation': organisation,
        'followerCount': followerCount,
        'followingCount': followingCount,
      };

  Drummer.fromSnapshot(snapshot)
      : badges = snapshot.data()['badges'],
        token = snapshot.data()['token'],
        uid = snapshot.data()['uid'],
        rid = snapshot.data()['rid'],
        name = snapshot.data()['name'],
        email = snapshot.data()['email'],
        speaking = snapshot.data()['speaking'],
        muted = snapshot.data()['muted'],
        username = snapshot.data()['username'],
        occupation = snapshot.data()['occupation'],
        bio = snapshot.data()['bio'],
        imageUrl = snapshot.data()['imageUrl'],
        organisation = snapshot.data()['organisation'],
        followerCount = snapshot.data()['followerCount'],
        followingCount = snapshot.data()['followingCount'],
        jobTitle = snapshot.data()['jobTitle'];

  Drummer.fromAlgoliaSnapshot(snapshot)
      : token = snapshot['token'],
        uid = snapshot['uid'],
        name = snapshot['name'],
        email = snapshot['email'],
        rid = snapshot['rid'],
        username = snapshot['username'],
        occupation = snapshot['occupation'],
        speaking = snapshot['speaking'],
        muted = snapshot['muted'],
        //badges = int.parse(snapshot['badges']),
        bio = snapshot['bio'],
        jobTitle = snapshot['jobTitle'],
        organisation = snapshot['organisation'],
        followerCount = snapshot['followerCount'],
        followingCount = snapshot['followingCount'],
        imageUrl = snapshot['imageUrl'];
}
