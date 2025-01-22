import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_bands.dart';
import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_current_user_bands.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_event.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteBandsBloc
    extends Bloc<RemoteBandEvent, RemoteBandsState> {
  final GetCurrentUserBandsUseCase getCurrentUserBands;
  final GetBandsUseCase getBandsUseCase;

  RemoteBandsBloc(this.getCurrentUserBands, this.getBandsUseCase)
      : super(const RemoteBandsLoading()) {
    on<GetCurrentUserBands>(onGetCurrentUserBands);
    on<GetBands>(onGetBands);
  }

  void onGetCurrentUserBands(
      GetCurrentUserBands event, Emitter<RemoteBandsState> emit) async {
    final dataState = await getCurrentUserBands();

    if (dataState is DataSuccess) {
      emit(RemoteBandsFetched(dataState.data!));

    }
    if (dataState is DataFailed) {
      emit(RemoteBandsError(dataState.error!));
    }
  }

  void onGetBands(
      GetBands event, Emitter<RemoteBandsState> emit) async {
    final dataState = await getBandsUseCase(params: event.bandIds);

    if (dataState is DataSuccess) {
      emit(RemoteBandsFetched(dataState.data!));

    }
    if (dataState is DataFailed) {
      emit(RemoteBandsError(dataState.error!));
    }
  }
}
