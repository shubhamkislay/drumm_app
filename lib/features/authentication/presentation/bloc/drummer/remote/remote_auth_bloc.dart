import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer.dart';
import 'package:drumm_app/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_auth_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteAuthBloc extends Bloc<RemoteAuthEvent,RemoteAuthState>{

  final IsAuthenticatedUseCase isAuthenticatedUseCase;

  RemoteAuthBloc(this.isAuthenticatedUseCase) : super(const RemoteAuthLoading()){
    on <IsAuthenticated> (onIsAuthenticated);
  }


  void onIsAuthenticated(IsAuthenticated event, Emitter<RemoteAuthState> emit)async{
    final dataState =  isAuthenticatedUseCase(params: event.uid);
    RemoteDrummerAuthenticated(dataState);
  }


}