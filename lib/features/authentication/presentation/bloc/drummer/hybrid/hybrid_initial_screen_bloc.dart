import 'package:drumm_app/features/authentication/domain/usecases/get_initial_screen.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HybridInitialScreenBloc
    extends Bloc<HybridInitialScreenEvent, HybridInitialScreenState> {
  final GetInitialScreenUseCase getInitialScreenUseCase;

  HybridInitialScreenBloc(this.getInitialScreenUseCase)
      : super(const FetchingInitialScreen()) {
    on<GetInitialScreen>(onGetInitialScreen);
  }

  void onGetInitialScreen(
      GetInitialScreen event, Emitter<HybridInitialScreenState> emit) async {
    final initialScreen = await getInitialScreenUseCase(params: event.uid);
    emit(InitialScreenFetched(initialScreen));
  }
}
