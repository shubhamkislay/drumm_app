// domain/usecases/mute_drumm_audio_usecase.dart

import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';

class MuteDrummAudioUseCase {
  final IDrummRepository repository;

  MuteDrummAudioUseCase(this.repository);

  Future<void> call(bool muted) {
    return repository.muteLocalAudio(muted);
  }
}
