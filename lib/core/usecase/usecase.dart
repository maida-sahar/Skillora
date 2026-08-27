/// Abstract class for standard Clean Architecture UseCases
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

class NoParams {
  const NoParams();
}
