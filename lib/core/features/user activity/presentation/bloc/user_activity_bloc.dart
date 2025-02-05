import 'package:drumm_app/core/features/user%20activity/domain/usecases/record_user_activity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserActivityBloc
    extends Bloc<UserActivityEvent, UserActivityState> {
  final RecordUserActivityUseCase recordUserActivityUseCase;

  UserActivityBloc(this.recordUserActivityUseCase)
      : super(const UserActivityIdle()) {
    on<RecordUserActivity>(onRecordUserActivity);
  }

  void onRecordUserActivity(
      RecordUserActivity event, Emitter<UserActivityState> emit) async {
    recordUserActivityUseCase(params: event.userActivityEntity);
  }
}
