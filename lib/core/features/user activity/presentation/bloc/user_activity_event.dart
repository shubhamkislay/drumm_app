import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';

abstract class UserActivityEvent{
  const UserActivityEvent();
}

class RecordUserActivity extends UserActivityEvent{
  final UserActivityEntity userActivityEntity;
  const RecordUserActivity(this.userActivityEntity);
}