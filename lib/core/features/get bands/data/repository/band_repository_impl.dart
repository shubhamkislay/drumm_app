import 'package:drumm_app/core/features/get%20bands/data/data_sources/remote/band_service.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/domain/repository/band_repository.dart';
import 'package:drumm_app/core/resources/data_state.dart';

class BandRepositoryImpl implements BandRepository {
  BandService bandService;

  BandRepositoryImpl(this.bandService);

  @override
  Future<DataState<List<BandEntity>>> getBands({List<String>? bandIds}) {
    return bandService.getBands(bandIds: bandIds);
  }

  @override
  Future<DataState<List<BandEntity>>> getCurrentUserBands() {
    return bandService.getCurrentUserBands();
  }
}
