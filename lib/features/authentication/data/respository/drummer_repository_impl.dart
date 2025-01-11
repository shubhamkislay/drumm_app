import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/firebase_service.dart';
import 'package:drumm_app/features/authentication/data/models/drummer.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';
import 'package:drumm_app/features/authentication/domain/repository/drummer_repository.dart';

class DrummerRepositoryImpl implements DrummerRepository {
  final FirebaseService firebaseService;

  DrummerRepositoryImpl(this.firebaseService);

  @override
  Future<DataState<DrummerModel>> getDrummer(String uid) {
    return firebaseService.getDrummer(uid);
  }

}