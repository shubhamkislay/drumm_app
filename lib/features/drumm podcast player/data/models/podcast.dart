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
}
