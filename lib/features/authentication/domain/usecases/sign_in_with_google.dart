import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/usecase/usecase.dart';
import 'package:drumm_app/features/authentication/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<DataState<String>, void> {
  final AuthRepository drummerRepository;

  SignInWithGoogleUseCase(this.drummerRepository);
  @override
  Future<DataState<String>> call({void params}) async {
    try {
      var route = "/";
      var googleAuthDataState = await drummerRepository.getGoogleCredential();
      if (googleAuthDataState is DataSuccess) {
        var userCredentialState = await drummerRepository
            .getUserCredential(googleAuthDataState.data!);
        var userIdState = drummerRepository.getDrummerId();

        var drummerState =
            await drummerRepository.getDrummer(userIdState.data!);

        String? uname = drummerState.data?.username!;

        if (userExists(uname ?? "")) {
          var onBoardedDataState = await drummerRepository.isUserOnboarded();
          if (onBoardedDataState is DataSuccess) {
            bool isUserOnboarded = onBoardedDataState.data!;
            if (isUserOnboarded) {
              route = "/newsDiscovery";
            } else {
              route = "/interestsPage";
            }
          } else {
            route = "/interestsPage";
          }
        } else {
          String? displayName = userCredentialState.data?.user?.displayName;
          String? email = userCredentialState.data?.user?.email;
          route = "/register?name=$displayName/email=${email}";
        }
        return DataSuccess(route);
      } else {
        return DataFailed(DioException(
            requestOptions: RequestOptions(),
            message:
                "Failed to get Google credential. ${googleAuthDataState.error!.message}"));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  bool userExists(String uname) {
    return uname.isNotEmpty;
  }
}
