// domain/usecases/leave_drumm_usecase.dart

import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';

class LeaveDrummUseCase {
  final IDrummRepository repository;

  LeaveDrummUseCase(this.repository);

  Future<void> call() {
    return repository.leaveChannel();
  }
}
