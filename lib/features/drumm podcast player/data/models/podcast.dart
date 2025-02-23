import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
class PodcastModel extends PodcastEntity {
  PodcastModel({
    required String audioTitle,
    required String podcastTitle,
    required String audioUrl,
    required int requestStatus,
    required DateTime updatedAt,
  }) : super(
    audioTitle: audioTitle,
    podcastTitle: podcastTitle,
    audioUrl: audioUrl,
    requestStatus: requestStatus,
    updatedAt: updatedAt,
  );

  factory PodcastModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastModel(
      audioTitle: data['audio_title'] ?? '',
      podcastTitle: data['podcast_title'] ?? '',
      audioUrl: data['audio_url'] ?? '',
      requestStatus: data['request_status'] ?? 0,
      // Convert Firestore's Timestamp to DateTime
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PodcastModel.fromJsonObject(Map<Object?, Object?> json)
      : super(
    audioTitle: json['audioTitle']?.toString() ?? '',
    podcastTitle: json['podcastTitle']?.toString() ?? '',
    audioUrl: json['audioUrl']?.toString() ?? '',
    requestStatus: int.tryParse(json['requestStatus']?.toString() ?? '0') ?? 0,
    updatedAt: json['updatedAt'] != null
        ? Timestamp.fromMicrosecondsSinceEpoch(
      int.tryParse(json['updatedAt']?.toString() ?? '0') ?? 0,
    ).toDate()
        : DateTime.now(),
  );


  factory PodcastModel.fromJson(Map<String, dynamic> json) {
      return PodcastModel(
          audioTitle: json['audio_title'] as String,
          podcastTitle: json['podcast_title'] as String,
          audioUrl: json['audio_url'] as String,
          requestStatus: json['request_status'] as int,
          updatedAt: Timestamp.fromMicrosecondsSinceEpoch(json['updatedAt']).toDate(),
      );

  }
}
