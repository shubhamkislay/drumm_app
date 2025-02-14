abstract class MusicPlayerEvent {}

class LoadMusic extends MusicPlayerEvent {
  final String url;
  LoadMusic(this.url);
}

class PlayMusic extends MusicPlayerEvent {}

class PauseMusic extends MusicPlayerEvent {}

class StopMusic extends MusicPlayerEvent {}  // New event to stop/end the music

class SeekMusic extends MusicPlayerEvent {
  final Duration position;
  SeekMusic(this.position);
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
  AudioPlayerStateChanged({required this.isPlaying});
}