import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DrummerEntity extends Equatable {
  final String? token;
  final String? uid;
  final String? name;
  final String? email;
  final String? username;
  final String? bio;
  final String? occupation;
  final int? badges;
  final VectorValue? preference;
  final Timestamp? lastRecommendationTimestamp;
  final String? imageUrl;
  final String? jobTitle;
  final String? organisation;
  final int? followerCount;
  final int? rid;
  final int? followingCount;
  final bool? speaking;
  final bool? muted;

  const DrummerEntity({
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

  DrummerEntity.fromSnapshot(snapshot)
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

  @override
  List<Object?> get props => [uid];
}
