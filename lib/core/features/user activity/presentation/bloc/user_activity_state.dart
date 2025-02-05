import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UserActivityState extends Equatable{
  final UserActivityEntity ? userActivityEntity;

  const UserActivityState({this.userActivityEntity});

  @override
  List<Object> get props => [userActivityEntity!];
}

class UserActivityIdle extends UserActivityState{
  const UserActivityIdle();
}

