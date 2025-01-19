import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/domain/usecases/usecase.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';

class GetDrummerUseCase implements UseCase<DataState<DrummerEntity>, String>{

  final DrummerRepository drummerRepository;

  GetDrummerUseCase(this.drummerRepository);

  @override
  Future<DataState<DrummerEntity>> call({String? params}) {
    return drummerRepository.getDrummer(params??"");
  }
}