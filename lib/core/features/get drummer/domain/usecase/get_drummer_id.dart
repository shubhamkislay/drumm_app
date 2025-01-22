import 'package:drumm_app/core/features/get%20drummer/domain/repository/drummer_repository.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';

class GetDrummerIdUseCase implements UseCaseSynchronous<DataState<String>,void>{
  DrummerRepository drummerRepository;

  GetDrummerIdUseCase(this.drummerRepository);
  @override
  DataState<String> call({void params}) {
    return drummerRepository.getDrummerId();
  }

}