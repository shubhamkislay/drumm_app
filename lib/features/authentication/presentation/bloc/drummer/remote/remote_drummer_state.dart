import 'package:dio/dio.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteDrummerState extends Equatable{
  final DrummerEntity ? drummerEntity;
  final DioException ? error;
  final bool ? isAuthenticated;

  const RemoteDrummerState({this.drummerEntity, this.error, this.isAuthenticated});

  @override
  List<Object> get props => [drummerEntity!, error!];
}

class RemoteDrummerLoading extends RemoteDrummerState{
  const RemoteDrummerLoading();
}

class RemoteDrummerDone extends RemoteDrummerState{
  const RemoteDrummerDone(DrummerEntity drummerEntity) : super(drummerEntity: drummerEntity);
}

class RemoteDrummerError extends RemoteDrummerState{
  const RemoteDrummerError(DioException error) : super(error: error);
}

class RemoteDrummerAuthenticated extends RemoteDrummerState{
  const RemoteDrummerAuthenticated(bool isAuthenticated) : super(isAuthenticated: isAuthenticated);
}



