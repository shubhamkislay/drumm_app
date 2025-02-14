import 'package:dio/dio.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/repository/drummer_repository.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
class GetDrummerByRidUseCase implements UseCase<DataState<DrummerEntity>, int?>{

  final DrummerRepository drummerRepository;

  GetDrummerByRidUseCase(this.drummerRepository);

  @override
  Future<DataState<DrummerEntity>> call({int? params}) {
    return drummerRepository.getDrummerByRid(rid: params);
  }
}