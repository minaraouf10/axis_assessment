import '../../../../core/utils/app_import.dart';

class GetLatestRatesWithChange {
  const GetLatestRatesWithChange(this._repository);

  final ExchangeRepository _repository;

  Future<Either<Failure, List<CurrencyRate>>> call() {
    return _repository.getLatestRatesWithChange();
  }
}
