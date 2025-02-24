import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';

abstract class MusicPlayerEvent {
  PodcastEntity? podcast;

}

class LoadMusic extends MusicPlayerEvent {
  final PodcastEntity? podcast;
  LoadMusic(this.podcast);
}

class PlayMusic extends MusicPlayerEvent {
  final PodcastEntity? podcast;
  PlayMusic(this.podcast);
}

class PauseMusic extends MusicPlayerEvent {
  final PodcastEntity? podcast;
  PauseMusic(this.podcast);
}

class StopMusic extends MusicPlayerEvent {
  final PodcastEntity? podcast;
  StopMusic(this.podcast);
}  // New event to stop/end the music

class SeekMusic extends MusicPlayerEvent {
  final Duration position;
  final PodcastEntity? podcast;
  SeekMusic(this.position,this.podcast);
}

class PositionChanged extends MusicPlayerEvent {
  final Duration position;
  PositionChanged(this.position);
}

class DurationChanged extends MusicPlayerEvent {
  final Duration? duration;
  DurationChanged(this.duration);
}

class AudioPlayerStateChanged extends MusicPlayerEvent {
  final bool isPlaying;
  final bool isProcessing;
  AudioPlayerStateChanged({required this.isPlaying, required this.isProcessing});
}