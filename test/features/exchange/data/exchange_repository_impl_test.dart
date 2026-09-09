import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/features/exchange/data/datasources/exchange_local_data_source.dart';
import 'package:axis_assessment/features/exchange/data/datasources/exchange_remote_data_source.dart';
import 'package:axis_assessment/features/exchange/data/models/currency_rate_model.dart';
import 'package:axis_assessment/features/exchange/data/models/historical_point_model.dart';
import 'package:axis_assessment/features/exchange/data/repositories/exchange_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements ExchangeRemoteDataSource {}

class MockLocal extends Mock implements ExchangeLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late MockNetworkInfo networkInfo;
  late ExchangeRepositoryImpl repository;

  final rates = [
    CurrencyRateModel(
      code: 'USD',
      name: 'US Dollar',
      rateInEgp: 48,
      lastUpdated: DateTime(2026, 9, 8),
      isFromCache: false,
    ),
  ];

  final cachedRates = [
    CurrencyRateModel(
      code: 'USD',
      name: 'US Dollar',
      rateInEgp: 48,
      lastUpdated: DateTime(2026, 9, 8),
      isFromCache: true,
    ),
  ];

  final history = [
    HistoricalPointModel(date: DateTime(2026, 9, 8), rateInEgp: 48),
  ];

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    networkInfo = MockNetworkInfo();
    repository = ExchangeRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
  });

  group('getLatestRatesWithChange', () {
    test('fetches remote data and caches it when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchLatestRatesWithChange())
          .thenAnswer((_) async => rates);
      when(() => local.cacheLatestRates(rates)).thenAnswer((_) async {});

      final result = await repository.getLatestRatesWithChange();

      expect(result.isRight(), isTrue);
      verify(() => local.cacheLatestRates(rates)).called(1);
    });

    test('falls back to stale cached rates when online but remote throws ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchLatestRatesWithChange())
          .thenThrow(const ServerException('API Timeout'));
      when(() => local.getCachedLatestRates())
          .thenAnswer((_) async => cachedRates);

      final result = await repository.getLatestRatesWithChange();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected success with stale cache'),
        (ratesList) => expect(ratesList.first.isFromCache, isTrue),
      );
    });

    test('returns ServerFailure when online, remote throws ServerException and local has no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchLatestRatesWithChange())
          .thenThrow(const ServerException('API Timeout'));
      when(() => local.getCachedLatestRates())
          .thenThrow(const CacheException('No cache'));

      final result = await repository.getLatestRatesWithChange();

      expect(result, const Left(ServerFailure('API Timeout')));
    });

    test('returns cached rates when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedLatestRates())
          .thenAnswer((_) async => cachedRates);

      final result = await repository.getLatestRatesWithChange();

      expect(result.isRight(), isTrue);
      verifyNever(() => remote.fetchLatestRatesWithChange());
    });

    test(
      'returns NetworkFailure when offline and the cache is empty',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(() => local.getCachedLatestRates())
            .thenThrow(const CacheException('empty'));

        final result = await repository.getLatestRatesWithChange();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('expected failure'),
        );
      },
    );
  });

  group('getHistoricalRates', () {
    test('fetches and caches history when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchHistoricalRates('USD'))
          .thenAnswer((_) async => history);
      when(
        () => local.cacheHistoricalRates(currencyCode: 'USD', points: history),
      ).thenAnswer((_) async {});

      final result = await repository.getHistoricalRates('USD');

      expect(result.isRight(), isTrue);
      verify(
        () => local.cacheHistoricalRates(currencyCode: 'USD', points: history),
      ).called(1);
    });

    test(
      'falls back to stale cache when online but remote throws ServerException',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.fetchHistoricalRates('USD'))
            .thenThrow(const ServerException('Server down'));
        when(() => local.getCachedHistoricalRates('USD'))
            .thenAnswer((_) async => history);

        final result = await repository.getHistoricalRates('USD');

        expect(result.isRight(), isTrue);
      },
    );

    test(
      'returns ServerFailure when online, remote fails and local has no cache',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.fetchHistoricalRates('USD'))
            .thenThrow(const ServerException('Server down'));
        when(() => local.getCachedHistoricalRates('USD'))
            .thenThrow(const CacheException('No cache'));

        final result = await repository.getHistoricalRates('USD');

        expect(result, const Left(ServerFailure('Server down')));
      },
    );

    test('returns NetworkFailure for history when offline and no cached history exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedHistoricalRates('USD'))
          .thenThrow(const CacheException('No cache'));

      final result = await repository.getHistoricalRates('USD');

      expect(result, const Left(NetworkFailure()));
    });
  });
}
