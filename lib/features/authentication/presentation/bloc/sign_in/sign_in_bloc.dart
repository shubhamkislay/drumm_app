import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInWithAppleUseCase signInWithAppleUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  SignInBloc(this.signInWithAppleUseCase, this.signInWithGoogleUseCase) : super(const SignInIdle()) {
    on<SignInWithApple>(onSignInWithApple);
    on<SignInWithGoogle>(onSignInWithGoogle);
  }

  void onSignInWithApple(
      SignInWithApple event, Emitter<SignInState> emit) async {
    emit(AppleSignInitiated());
    final dataState = await signInWithAppleUseCase();
    if (dataState is DataSuccess) {
      emit(SignInCompleted(dataState.data!));
    } else {
      emit(SignInFailed(dataState.error!));
    }
  }

  void onSignInWithGoogle(
      SignInWithGoogle event, Emitter<SignInState> emit) async {
    emit(GoogleSignInitiated());
    final dataState = await signInWithGoogleUseCase();
    if (dataState is DataSuccess) {
      emit(SignInCompleted(dataState.data!));
    } else {
      emit(SignInFailed(dataState.error!));
    }
  }

}
