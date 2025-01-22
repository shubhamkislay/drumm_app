import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteBandsState extends Equatable{
  final List<BandEntity> ? bands;
  final DioException ? error;

  const RemoteBandsState({this.bands, this.error});

  @override
  List<Object> get props => [bands!,error??DioException(requestOptions: RequestOptions())];
}

class RemoteBandsLoading extends RemoteBandsState{
  const RemoteBandsLoading();
}

class RemoteBandsFetched extends RemoteBandsState{
  const RemoteBandsFetched(List<BandEntity> bands) : super(bands: bands);
}

class RemoteBandsError extends RemoteBandsState{
  const RemoteBandsError(DioException error) : super(error: error);
}
