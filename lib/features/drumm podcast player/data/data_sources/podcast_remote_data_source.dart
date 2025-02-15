import 'package:drumm_app/features/drumm%20podcast%20player/data/models/podcast.dart';

abstract class PodcastRemoteDataSource {
  Future<List<PodcastModel>> getPodcastsWhereStatusIs100();
}
