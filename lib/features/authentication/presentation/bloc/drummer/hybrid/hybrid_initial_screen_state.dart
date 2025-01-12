import 'package:equatable/equatable.dart';

abstract class HybridInitialScreenState extends Equatable{

  final String ? initialScreen;
  const HybridInitialScreenState({this.initialScreen});

  @override
  List<Object> get props => [initialScreen!];
}

class FetchingInitialScreen extends HybridInitialScreenState{
  const FetchingInitialScreen();
}

class InitialScreenFetched extends HybridInitialScreenState{
  const InitialScreenFetched(String initialScreen) : super(initialScreen: initialScreen);
}



