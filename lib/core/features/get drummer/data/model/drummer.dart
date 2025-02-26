import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';

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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (token != null) data['token'] = token;
    if (name != null) data['name'] = name;
    if (rid != null) data['rid'] = rid;
    if (email != null) data['email'] = email;
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (badges != null) data['badges'] = badges;
    if (uid != null) data['uid'] = uid;
    if (occupation != null) data['occupation'] = occupation;
    if (speaking != null) data['speaking'] = speaking;
    if (muted != null) data['muted'] = muted;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (lastRecommendationTimestamp != null) {
      data['lastRecommendationTimestamp'] = lastRecommendationTimestamp;
    }
    if (preference != null) data['preference'] = preference;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (organisation != null) data['organisation'] = organisation;
    if (followerCount != null) data['followerCount'] = followerCount;
    if (followingCount != null) data['followingCount'] = followingCount;

    return data;
  }


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
