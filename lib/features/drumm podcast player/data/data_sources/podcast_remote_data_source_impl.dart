// feature/data/datasources/podcast_remote_data_source_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/data/models/podcast.dart';

import 'podcast_remote_data_source.dart';

class PodcastService{

  PodcastService();

  @override
  Future<List<PodcastModel>> getPodcastsWhereStatusIs100() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('podcastRequests')
        .where('status', isEqualTo: 100)
        .orderBy('updatedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PodcastModel.fromDocument(doc))
        .toList();
  }
}
