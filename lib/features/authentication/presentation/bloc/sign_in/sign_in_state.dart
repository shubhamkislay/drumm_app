import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class SignInState extends Equatable{
  final String ? route;
  final DioException ? error;

  const SignInState({this.error,this.route});

  @override
  List<Object> get props => [route!, error!];
}

class SignInIdle extends SignInState{
  const SignInIdle();
}

class AppleSignInitiated extends SignInState{
  const AppleSignInitiated();
}

class GoogleSignInitiated extends SignInState{
  const GoogleSignInitiated();
}

class SignInCompleted extends SignInState{
  const SignInCompleted(String route) : super(route: route);
}

class SignInFailed extends SignInState{
  const SignInFailed(DioException error) : super(error: error);
}

