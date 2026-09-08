import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/features/exchange/domain/entities/currency_rate.dart';
import 'package:axis_assessment/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:axis_assessment/features/exchange/domain/usecases/get_historical_rates.dart';
import 'package:axis_assessment/features/exchange/domain/usecases/get_latest_rates_with_change.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockExchangeRepository extends Mock implements ExchangeRepository {}

void main() {
  late MockExchangeRepository repository;

  setUp(() {
    repository = MockExchangeRepository();
  });

  group('GetLatestRatesWithChange', () {
    test('returns rates from the repository', () async {
      final rates = [sampleRate()];
      when(
        () => repository.getLatestRatesWithChange(),
      ).thenAnswer((_) async => Right(rates));

      final result = await GetLatestRatesWithChange(repository)();

      expect(result, Right<Failure, List<CurrencyRate>>(rates));
      verify(() => repository.getLatestRatesWithChange()).called(1);
    });

    test('forwards a server failure', () async {
      const failure = ServerFailure('down');
      when(
        () => repository.getLatestRatesWithChange(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await GetLatestRatesWithChange(repository)();

      expect(result, const Left<Failure, List<CurrencyRate>>(failure));
    });
  });

  group('GetHistoricalRates', () {
    test('returns history for the requested currency', () async {
      final history = sampleHistory();
      when(
        () => repository.getHistoricalRates('USD'),
      ).thenAnswer((_) async => Right(history));

      final result = await GetHistoricalRates(repository)('USD');

      expect(result.isRight(), isTrue);
      verify(() => repository.getHistoricalRates('USD')).called(1);
    });
  });
}
