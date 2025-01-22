import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/resources/data_state.dart';

abstract class BandRepository{

  Future<DataState<List<BandEntity>>> getCurrentUserBands();

  Future<DataState<List<BandEntity>>> getBands({List<String>? bandIds});

}