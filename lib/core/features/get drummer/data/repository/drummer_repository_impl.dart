import 'package:drumm_app/core/features/get%20drummer/data/data_sources/remote/drummer_service.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/repository/drummer_repository.dart';
import 'package:drumm_app/core/resources/data_state.dart';

class DrummerRepositoryImpl implements DrummerRepository {
  final DrummerService drummerService;

  DrummerRepositoryImpl(this.drummerService);

  @override
  Future<DataState<DrummerEntity>> getDrummer({String ? uid}) {
    return drummerService.getDrummer(uid: uid);
  }

  @override
  DataState<String> getDrummerId() {
    return drummerService.getDrummerId();
  }

  @override
  Future<DataState<DrummerEntity>> getDrummerByRid({int? rid}) {
    return drummerService.getDrummerByRid(rid: rid);
  }

}
