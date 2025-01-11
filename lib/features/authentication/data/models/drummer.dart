import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';

class DrummerModel extends DrummerEntity {
  String? token;
  String? uid;
  String? name;
  String? email;
  String? username;
  String? bio;
  String? occupation;
  int? badges;
  VectorValue? preference;
  Timestamp? lastRecommendationTimestamp;
  String? imageUrl;
  String? jobTitle;
  String? organisation;
  int? followerCount;
  int? rid;
  int? followingCount;
  bool? speaking;
  bool? muted;

   DrummerModel({
    this.badges,
    this.followerCount,
    this.followingCount,
    this.speaking,
    this.muted,
    this.uid,
    this.token,
    this.name,
    this.email,
    this.username,
    this.bio,
    this.occupation,
    this.preference,
    this.lastRecommendationTimestamp,
    this.imageUrl,
    this.jobTitle,
    this.organisation,
    this.rid,
  });

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

  factory DrummerModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return DrummerModel(
      token : snapshot.data()!['token'],
      uid : snapshot.data()?['uid'],
      name : snapshot.data()?['name'],
      badges : snapshot.data()?['badges'],
      email : snapshot.data()?['email'],
      rid : snapshot.data()?['rid'],
      username : snapshot.data()?['username'],
      occupation : snapshot.data()?['occupation'],
      speaking : snapshot.data()?['speaking'],
      muted : snapshot.data()?['muted'],
      imageUrl : snapshot.data()?['imageUrl'],
      lastRecommendationTimestamp : snapshot.data()?['lastRecommendationTimestamp'],
      preference : snapshot.data()?['preference'],
      bio : snapshot.data()?['bio'],
      jobTitle : snapshot.data()?['jobTitle'],
      organisation : snapshot.data()?['organisation'],
      followerCount : snapshot.data()?['followerCount'],
      followingCount : snapshot.data()?['followingCount'],
    );
  }
}
