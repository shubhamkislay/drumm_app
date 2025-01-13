import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecases/usecase.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';

class GetDrummerIdUseCase implements UseCaseSynchronous<DataState<String>,void>{
  DrummerRepository drummerRepository;

  GetDrummerIdUseCase(this.drummerRepository);
  @override
  DataState<String> call({void params}) {
    return drummerRepository.getDrummerId();
  }

}