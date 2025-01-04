import 'package:cloud_firestore/cloud_firestore.dart';

class Drummer {
  String? token;
  String? uid;
  String? name;
  String? email;
  String? username;
  String? bio;
  String? occupation;
  int? badges = 0;
  VectorValue? preference;
  Timestamp? lastRecommendationTimestamp;
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
        'lastRecommendationTimestamp': lastRecommendationTimestamp,
        'preference': preference?.toArray(),
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
        preference = snapshot.data()['preference'],
        lastRecommendationTimestamp = snapshot.data()['lastRecommendationTimestamp'],
        imageUrl = snapshot.data()['imageUrl'],
        organisation = snapshot.data()['organisation'],
        followerCount = snapshot.data()['followerCount'],
        followingCount = snapshot.data()['followingCount'],
        jobTitle = snapshot.data()['jobTitle'];

  Drummer.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        uid = json['uid'],
        name = json['name'],
        email = json['email'],
        rid = json['rid'],
        username = json['username'],
        occupation = json['occupation'],
        speaking = json['speaking'],
        muted = json['muted'],
        imageUrl = json['imageUrl'],
        lastRecommendationTimestamp = json['lastRecommendationTimestamp'],
        preference = json['preference'] is List<dynamic>
            ? VectorValue(List<double>.from(json['preference'] as List<dynamic>))
            : null,
        bio = json['bio'],
        jobTitle = json['jobTitle'],
        organisation = json['organisation'],
        followerCount = json['followerCount'],
        followingCount = json['followingCount'];
}
