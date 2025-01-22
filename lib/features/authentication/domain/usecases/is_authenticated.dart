import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/authentication/domain/repository/auth_repository.dart';

class IsAuthenticatedUseCase implements UseCaseSynchronous<bool, void>{

  final AuthRepository drummerRepository;

  IsAuthenticatedUseCase(this.drummerRepository);

  @override
  bool call({void params}) {
    return drummerRepository.isAuthenticated();
  }
}