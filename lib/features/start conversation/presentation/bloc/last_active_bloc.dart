import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/update_last_active.dart';
import 'last_active_event.dart';
import 'last_active_state.dart';

class LastActiveBloc extends Bloc<LastActiveEvent, LastActiveState> {
  final UpdateLastActiveUseCase updateLastActiveUseCase;
  Timer? _timer;

  LastActiveBloc({
    required this.updateLastActiveUseCase,
  }) : super(LastActiveInitial()) {
    on<StartUpdatingLastActive>(_onStartUpdating);
    on<StopUpdatingLastActive>(_onStopUpdating);
  }

  void _onStartUpdating(StartUpdatingLastActive event, Emitter<LastActiveState> emit) {
    _timer?.cancel();
    // Start a periodic timer that fires every 10 seconds.
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final now = Timestamp.now();
        await updateLastActiveUseCase(event.conversationId, now);
        emit(LastActiveUpdated(lastActive: now));
      } catch (e) {
        emit(LastActiveError(message: e.toString()));
      }
    });
  }

  void _onStopUpdating(StopUpdatingLastActive event, Emitter<LastActiveState> emit) {
    _timer?.cancel();
    emit(LastActiveStopped());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
