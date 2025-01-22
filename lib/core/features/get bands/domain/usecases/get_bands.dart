import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/domain/repository/band_repository.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/core/resources/data_state.dart';

class GetBandsUseCase
    implements UseCase<DataState<List<BandEntity>>, List<String>?> {
  final BandRepository bandRepository;

  GetBandsUseCase(this.bandRepository);

  @override
  Future<DataState<List<BandEntity>>> call({List<String>? params}) async {
    try {
      var dataState = await bandRepository.getBands(bandIds: params);
      if (dataState is DataSuccess) {
        return DataSuccess(dataState.data!);
      } else {
        return DataFailed(dataState.error!);
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
