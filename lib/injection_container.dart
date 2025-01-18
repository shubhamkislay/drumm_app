import 'package:drumm_app/config/routes/page_routes.dart';
import 'package:drumm_app/features/authentication/data/data_sources/local/shared_preference_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/apple_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/firebase_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/google_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/respository/drummer_repository_impl.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_drummer.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_initial_screen.dart';
import 'package:drumm_app/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_drummer_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:get_it/get_it.dart';

final s1 = GetIt.instance;

Future<void> initializeDependencies() async {
  // Dependencies
  s1.registerSingleton<FirebaseService>(FirebaseService());
  s1.registerSingleton<SharedPreferenceService>(SharedPreferenceService());
  s1.registerSingleton<AppleSignInService>(AppleSignInService());
  s1.registerSingleton<GoogleSignInService>(GoogleSignInService());

  s1.registerSingleton<DrummerRepository>(DrummerRepositoryImpl(s1(), s1(),s1(),s1()));

  //UseCases
  s1.registerSingleton<GetDrummerUseCase>(GetDrummerUseCase(s1()));
  s1.registerSingleton<IsAuthenticatedUseCase>(IsAuthenticatedUseCase(s1()));
  s1.registerSingleton<GetInitialScreenUseCase>(GetInitialScreenUseCase(s1()));
  s1.registerSingleton<SignInWithAppleUseCase>(SignInWithAppleUseCase(s1()));
  s1.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(s1()));

  //Blocs
  s1.registerFactory<RemoteDrummerBloc>(() => RemoteDrummerBloc(s1(), s1()));
  s1.registerFactory<HybridInitialScreenBloc>(() => HybridInitialScreenBloc(s1()));
  s1.registerFactory<SignInBloc>(() => SignInBloc(s1(),s1()));
}
