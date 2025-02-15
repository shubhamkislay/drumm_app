import 'package:drumm_app/features/drumm%20podcast%20player/data/data_sources/podcast_remote_data_source.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/data/data_sources/podcast_remote_data_source_impl.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/repository/podcast_repository.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastService podcastService;

  PodcastRepositoryImpl(this.podcastService);

  @override
  Future<List<PodcastEntity>> fetchPodcasts() async {
    // You could add caching or local DB here if needed
    return podcastService.getPodcastsWhereStatusIs100();
  }
}
