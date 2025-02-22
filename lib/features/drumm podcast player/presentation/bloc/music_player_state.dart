import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';

class MusicPlayerState {
  final bool isPlaying;
  final Duration? duration;
  final Duration position;
  final PodcastEntity? podcast;

  const MusicPlayerState({
    required this.isPlaying,
    this.duration,
    required this.position,
    this.podcast,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    PodcastEntity? podcast,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      podcast: podcast ?? this.podcast,
    );
  }

}


class LoadingPlayerState extends MusicPlayerState{
  LoadingPlayerState({required super.isPlaying, required super.position, required super.podcast});
}