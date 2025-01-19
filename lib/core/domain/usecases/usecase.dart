abstract class UseCase<Type, Params> {
  Future<Type> call({Params params});
}

abstract class UseCaseSynchronous<Type, Params> {
  Type call({Params params});
}