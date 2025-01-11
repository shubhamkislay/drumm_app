import 'package:drumm_app/features/authentication/data/data_sources/remote/firebase_service.dart';
import 'package:drumm_app/features/authentication/data/respository/drummer_repository_impl.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_drummer.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_drummer_bloc.dart';
import 'package:get_it/get_it.dart';

final s1 = GetIt.instance;

Future<void> initializeDependencies() async {

  // Dependencies
  s1.registerSingleton<FirebaseService>(FirebaseService());

  s1.registerSingleton<DrummerRepository>(
    DrummerRepositoryImpl(s1())
  );

  //UseCases
  s1.registerSingleton<GetDrummerUseCase>(
    GetDrummerUseCase(s1())
  );

  //Blocs
  s1.registerFactory<RemoteDrummerBloc>(
      ()=> RemoteDrummerBloc(s1())
  );

}