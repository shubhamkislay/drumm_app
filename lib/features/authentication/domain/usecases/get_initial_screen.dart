import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/core/domain/usecases/usecase.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';
import 'package:flutter/foundation.dart';

class GetInitialScreenUseCase implements UseCase<String,String>{
  final DrummerRepository drummerRepository;

  GetInitialScreenUseCase(this.drummerRepository);

  @override
  Future<String> call({String ? params}) async {

    try {
      bool isAuthenticated = drummerRepository.isAuthenticated();
      if (!isAuthenticated) {
        return SCREEN_ONBOARDING;
      }
      bool isOnboarded = await drummerRepository.isOnboarded();
      if (isOnboarded) {
        return SCREEN_NEWS_DISCOVERY;
      }

      DataState<DrummerEntity> dataState = await drummerRepository.getDrummer(
          params!);

      if (dataState is DataSuccess) {
        DrummerEntity drummerEntity = dataState.data!;
        int userLen = drummerEntity.username?.length ?? 0;
        if (userLen > 0) {
          if (drummerEntity.occupation != null) {
            drummerRepository.setOnboarded();
            return SCREEN_NEWS_DISCOVERY;
          } else {
            return SCREEN_PROFESSIONAL;
          }
        }
      }
    }catch(e){
      if (kDebugMode) {
        print("Error fetching initialScreen $e");
      }
    }

    return SCREEN_REGISTER;
  }

}