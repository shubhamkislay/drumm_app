import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/domain/usecases/usecase.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';

class IsAuthenticatedUseCase implements UseCaseSynchronous<bool, void>{

  final DrummerRepository drummerRepository;

  IsAuthenticatedUseCase(this.drummerRepository);

  @override
  bool call({void params}) {
    return drummerRepository.isAuthenticated();
  }
}