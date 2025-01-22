import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/domain/repository/band_repository.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/core/resources/data_state.dart';

class GetCurrentUserBandsUseCase
    implements UseCase<DataState<List<BandEntity>>, void> {
  final BandRepository bandRepository;

  GetCurrentUserBandsUseCase(this.bandRepository);

  @override
  Future<DataState<List<BandEntity>>> call({void params}) async {
    try {
      var dataState = await bandRepository.getCurrentUserBands();
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
