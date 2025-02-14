import 'dart:async';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  MusicPlayerBloc()
      : super(const MusicPlayerState(
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
        await _audioPlayer.setUrl(event.url);
      } catch (e) {
        print("Error loading audio: $e");
      }
    });

    on<PlayMusic>((event, emit) async {
      await _audioPlayer.play();
      // The state will update via the playerStateStream listener.
    });

    on<PauseMusic>((event, emit) async {
      await _audioPlayer.pause();
    });

    on<StopMusic>((event, emit) async {
      // Stop the audio and reset the state.
      await _audioPlayer.stop();
      emit(MusicPlayerState(
        isPlaying: false,
        duration: Duration.zero,
        position: Duration.zero,
      ));
    });

    on<SeekMusic>((event, emit) async {
      await _audioPlayer.seek(event.position);
    });

    on<PositionChanged>((event, emit) {
      emit(state.copyWith(position: event.position));
    });

    on<DurationChanged>((event, emit) {
      emit(state.copyWith(duration: event.duration));
    });

    on<AudioPlayerStateChanged>((event, emit) {
      emit(state.copyWith(isPlaying: event.isPlaying));
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