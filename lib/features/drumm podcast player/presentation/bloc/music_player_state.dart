import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';

class MusicPlayerState {
  final bool isPlaying;
  final bool isProcessing;
  final Duration? duration;
  final Duration position;
  final PodcastEntity? podcast;

  const MusicPlayerState({
    required this.isPlaying,
    required this.isProcessing,
    this.duration,
    required this.position,
    this.podcast,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    bool? isProcessing,
    Duration? duration,
    Duration? position,
    PodcastEntity? podcast,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isProcessing: isProcessing ?? this.isProcessing,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      podcast: podcast ?? this.podcast,
    );
  }

}


class LoadingPlayerState extends MusicPlayerState{
  LoadingPlayerState({required super.isProcessing,required super.isPlaying, required super.position, required super.podcast});
}