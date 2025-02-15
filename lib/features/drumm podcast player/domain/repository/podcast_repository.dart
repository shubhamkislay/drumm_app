import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';

abstract class PodcastRepository {
  /// Fetch a list of podcasts where status = 100, sorted by updatedAt (desc).
  Future<List<PodcastEntity>> fetchPodcasts();
}
