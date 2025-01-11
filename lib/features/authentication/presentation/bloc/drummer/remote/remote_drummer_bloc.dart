import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_drummer.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_drummer_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_drummer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteDrummerBloc extends Bloc<RemoteDrummerEvent,RemoteDrummerState>{


  final GetDrummerUseCase getDrummerUseCase;

  RemoteDrummerBloc(this.getDrummerUseCase) : super(const RemoteDrummerLoading()){
    on <GetDrummer> (onGetDrummer);
  }

  void onGetDrummer(GetDrummer event, Emitter<RemoteDrummerState> emit)async{
    final dataState = await getDrummerUseCase(params: event.uid);

    if(dataState is DataSuccess){
      emit(
        RemoteDrummerDone(dataState.data!)
      );
    }

    if(dataState is DataFailed){
      emit(
        RemoteDrummerError(dataState.error!)
      );
    }
  }

}