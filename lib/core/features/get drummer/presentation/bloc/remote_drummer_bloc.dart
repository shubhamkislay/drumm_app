import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer_by_rid.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_event.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteDrummerBloc extends Bloc<RemoteDrummerEvent,RemoteDrummerState>{


  final GetDrummerUseCase getDrummerUseCase;
  final GetDrummerByRidUseCase getDrummerByRidUseCase;

  RemoteDrummerBloc(this.getDrummerUseCase, this.getDrummerByRidUseCase) : super(const RemoteDrummerLoading()){
    on <GetDrummer> (onGetDrummer);
    on <GetDrummerByRid>(onGetDrummerByRid);
  }

  void onGetDrummer(GetDrummer event, Emitter<RemoteDrummerState> emit)async{
    final dataState = await getDrummerUseCase(params: event.uid);

    if(dataState is DataSuccess){
      if(dataState.data!=null) {
        DrummerEntity drummerEntity = dataState.data??DrummerEntity();
        emit(
            RemoteDrummerDone(drummerEntity)
        );
      }else{
        emit(
            RemoteDrummerError(dataState.error!)
        );
      }
    }

    if(dataState is DataFailed){
      emit(
        RemoteDrummerError(dataState.error!)
      );
    }
  }

  void onGetDrummerByRid(GetDrummerByRid event, Emitter<RemoteDrummerState> emit)async{
    final dataState = await getDrummerByRidUseCase(params: event.rid);

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