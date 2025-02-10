// domain/usecases/join_drumm_usecase.dart

import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';

class JoinDrummUseCase {
  final IDrummRepository repository;

  JoinDrummUseCase(this.repository);

  Future<void> call({
    required String token,
    required String channelName,
    required int uid,
    required bool isMuted,
  }) {
    return repository.joinChannel(
      token: token,
      channelName: channelName,
      uid: uid,
      isMuted: isMuted,
    );
  }
}
