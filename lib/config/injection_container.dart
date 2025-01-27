import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/data/data_sources/remote/band_service.dart';
import 'package:drumm_app/core/features/get%20bands/data/repository/band_repository_impl.dart';
import 'package:drumm_app/core/features/get%20bands/domain/repository/band_repository.dart';
import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_bands.dart';
import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_current_user_bands.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/data/data_sources/remote/drummer_service.dart';
import 'package:drumm_app/core/features/get%20drummer/data/repository/drummer_repository_impl.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/repository/drummer_repository.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer_id.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/features/authentication/data/data_sources/local/shared_preference_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/apple_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/auth_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/google_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/respository/auth_repository_impl.dart';
import 'package:drumm_app/features/authentication/domain/repository/auth_repository.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_initial_screen.dart';
import 'package:drumm_app/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_auth_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:drumm_app/features/news%20feed/data/data_sources/remote/article_service.dart';
import 'package:drumm_app/features/news%20feed/data/respository/article_repository_impl.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_articles.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:get_it/get_it.dart';

final s1 = GetIt.instance;

Future<void> initializeDependencies() async {

  /**
   * Dependencies
   */
  //authentication
  s1.registerSingleton<AuthService>(AuthService());
  s1.registerSingleton<SharedPreferenceService>(SharedPreferenceService());
  s1.registerSingleton<AppleSignInService>(AppleSignInService());
  s1.registerSingleton<GoogleSignInService>(GoogleSignInService());
  //news feed
  s1.registerSingleton<ArticleService>(ArticleService());
  //core
  s1.registerSingleton<BandService>(BandService());
  s1.registerSingleton<DrummerService>(DrummerService());

  /**
   * Repositories
   */
  //authentication
  s1.registerSingleton<AuthRepository>(AuthRepositoryImpl(s1(), s1(),s1(),s1(),s1()));
  //news feed
  s1.registerSingleton<ArticleRepository>(ArticleRespositoryImpl(s1()));
  //core
  s1.registerSingleton<BandRepository>(BandRepositoryImpl(s1()));
  s1.registerSingleton<DrummerRepository>(DrummerRepositoryImpl(s1()));

  /**
   * UseCases
   */
  //authentication
  s1.registerSingleton<IsAuthenticatedUseCase>(IsAuthenticatedUseCase(s1()));
  s1.registerSingleton<GetInitialScreenUseCase>(GetInitialScreenUseCase(s1()));
  s1.registerSingleton<SignInWithAppleUseCase>(SignInWithAppleUseCase(s1()));
  s1.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(s1()));
  //news feed
  s1.registerSingleton<GetArticlesUseCase>(GetArticlesUseCase(s1()));
  //core
  s1.registerSingleton<GetBandsUseCase>(GetBandsUseCase(s1()));
  s1.registerSingleton<GetCurrentUserBandsUseCase>(GetCurrentUserBandsUseCase(s1()));
  s1.registerSingleton<GetDrummerUseCase>(GetDrummerUseCase(s1()));
  s1.registerSingleton<GetDrummerIdUseCase>(GetDrummerIdUseCase(s1()));

  /**
   * Bloc
   */
  //authentication
  s1.registerFactory<RemoteAuthBloc>(() => RemoteAuthBloc(s1()));
  s1.registerFactory<HybridInitialScreenBloc>(() => HybridInitialScreenBloc(s1()));
  s1.registerFactory<SignInBloc>(() => SignInBloc(s1(),s1()));
  //news feed
  s1.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(s1()));
  //core
  s1.registerFactory<RemoteDrummerBloc>(() => RemoteDrummerBloc(s1())); //get drummer
  s1.registerFactory<RemoteBandsBloc>(() => RemoteBandsBloc(s1(),s1())); //get band
}
