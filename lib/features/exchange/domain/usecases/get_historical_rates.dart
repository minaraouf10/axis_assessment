import '../../../../core/utils/app_import.dart';

class GetHistoricalRates {
  const GetHistoricalRates(this._repository);

  final ExchangeRepository _repository;

  Future<Either<Failure, List<HistoricalPoint>>> call(String currencyCode) {
    return _repository.getHistoricalRates(currencyCode);
  }
}
