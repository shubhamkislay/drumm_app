// STATES
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';

abstract class PodcastState {}

class PodcastInitial extends PodcastState {}

class PodcastLoading extends PodcastState {}

class PodcastLoaded extends PodcastState {
  final List<PodcastEntity> podcasts;
  PodcastLoaded(this.podcasts);
}

class PodcastError extends PodcastState {
  final String message;
  PodcastError(this.message);
}