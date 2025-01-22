import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class RemoteAuthState extends Equatable{
  final DioException ? error;
  final bool ? isAuthenticated;

  const RemoteAuthState({ this.error, this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated!, error!];
}

class RemoteAuthLoading extends RemoteAuthState{
  const RemoteAuthLoading();
}

class RemoteDrummerAuthenticated extends RemoteAuthState{
  const RemoteDrummerAuthenticated(bool isAuthenticated) : super(isAuthenticated: isAuthenticated);
}



