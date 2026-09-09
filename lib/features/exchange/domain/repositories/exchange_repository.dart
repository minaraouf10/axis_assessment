import 'package:axis_assessment/features/exchange/domain/domain.dart';

abstract class ExchangeRepository {
  Future<Either<Failure, List<CurrencyRate>>> getLatestRatesWithChange();

  Future<Either<Failure, List<HistoricalPoint>>> getHistoricalRates(
    String currencyCode,
  );
}
