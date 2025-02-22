import 'dart:async';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/podcast.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  PodcastEntity? podcast;

  MusicPlayerBloc()
      : super(MusicPlayerState(
    isPlaying: false,
    duration: Duration.zero,
    position: Duration.zero,
  )) {
    // Listen to the AudioPlayer's state stream.
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      add(AudioPlayerStateChanged(isPlaying: playerState.playing));
    });

    // Listen to the AudioPlayer's position stream.
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      add(PositionChanged(position));
    });

    // Listen to the AudioPlayer's duration stream.
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      add(DurationChanged(duration));
    });

    on<LoadMusic>((event, emit) async {
      try {
        podcast = event.podcast;
        await _audioPlayer.setUrl(event.podcast?.audioUrl??"");
      } catch (e) {
        print("Error loading audio: $e");
      }
    });

    on<PlayMusic>((event, emit) async {
      podcast = event.podcast;
      await _audioPlayer.play();
      // The state will update via the playerStateStream listener.
    });

    on<PauseMusic>((event, emit) async {
      podcast = event.podcast;
      await _audioPlayer.pause();
    });

    on<StopMusic>((event, emit) async {
      podcast = event.podcast;
      // Stop the audio and reset the state.
      await _audioPlayer.stop();
      emit(MusicPlayerState(
        isPlaying: false,
        duration: Duration.zero,
        position: Duration.zero,
        podcast: event.podcast
      ));
    });

    on<SeekMusic>((event, emit) async {
      podcast = event.podcast;
      await _audioPlayer.seek(event.position);
    });

    on<PositionChanged>((event, emit) {
      emit(state.copyWith(position: event.position,podcast: podcast));
    });

    on<DurationChanged>((event, emit) {
      emit(state.copyWith(duration: event.duration,podcast: podcast));
    });

    on<AudioPlayerStateChanged>((event, emit) {
      emit(state.copyWith(isPlaying: event.isPlaying,podcast: podcast));
    });
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}