import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/repository/podcast_repository.dart';

class FetchPodcastsUseCase {
  final PodcastRepository repository;

  FetchPodcastsUseCase(this.repository);

  /// Executes the use case: fetch podcasts from repository.
  Future<List<PodcastEntity>> call() async {
    return repository.fetchPodcasts();
  }
}
