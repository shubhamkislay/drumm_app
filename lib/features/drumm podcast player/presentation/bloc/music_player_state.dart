class MusicPlayerState {
  final bool isPlaying;
  final Duration? duration;
  final Duration position;

  const MusicPlayerState({
    required this.isPlaying,
    this.duration,
    required this.position,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    Duration? duration,
    Duration? position,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}