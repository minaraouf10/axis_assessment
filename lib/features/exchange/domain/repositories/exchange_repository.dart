import '../../../../core/utils/app_import.dart';

abstract class ExchangeRepository {
  Future<Either<Failure, List<CurrencyRate>>> getLatestRatesWithChange();

  Future<Either<Failure, List<HistoricalPoint>>> getHistoricalRates(
    String currencyCode,
  );
}
