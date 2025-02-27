import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteDrummerState extends Equatable{
  final DrummerEntity ? drummerEntity;
  final DioException ? error;

  const RemoteDrummerState({this.drummerEntity, this.error});

  @override
  List<Object> get props => [drummerEntity??DrummerEntity(), error??DioException(requestOptions: RequestOptions())];
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



