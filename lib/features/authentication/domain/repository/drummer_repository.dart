import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/authentication/domain/entities/drummer.dart';

abstract class DrummerRepository{

  Future<DataState<DrummerEntity>> getDrummer(String uid);
}