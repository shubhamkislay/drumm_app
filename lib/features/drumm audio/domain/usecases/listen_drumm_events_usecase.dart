// domain/usecases/listen_drumm_events_usecase.dart


import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_remote_event.dart';
import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';

class ListenDrummEventsUseCase {
  final IDrummRepository repository;

  ListenDrummEventsUseCase(this.repository);

  Stream<DrummRemoteEvent> call() {
    return repository.getRemoteEvents();
  }
}
