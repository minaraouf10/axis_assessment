import 'dart:convert';
import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/features/exchange/data/datasources/exchange_local_data_source.dart';
import 'package:axis_assessment/features/exchange/data/models/currency_rate_model.dart';
import 'package:axis_assessment/features/exchange/data/models/historical_point_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox mockBox;
  late ExchangeLocalDataSourceImpl localDataSource;

  setUp(() {
    mockBox = MockBox();
    localDataSource = ExchangeLocalDataSourceImpl(mockBox);
  });

  final testRate = CurrencyRateModel(
    code: 'USD',
    name: 'US Dollar',
    rateInEgp: 48.5,
    lastUpdated: DateTime(2026, 9, 8, 12),
    dailyChange: 0.1,
    dailyChangePercent: 0.2,
  );

  final testPoint = HistoricalPointModel(
    date: DateTime(2026, 9, 8),
    rateInEgp: 48.5,
  );

  group('cacheLatestRates & getCachedLatestRates', () {
    test('successfully caches latest rates', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await localDataSource.cacheLatestRates([testRate]);

      verify(() => mockBox.put(ExchangeLocalDataSourceImpl.ratesKey, any())).called(1);
    });

    test('retrieves cached latest rates and sets isFromCache to true', () async {
      final jsonStr = jsonEncode([testRate.toJson()]);
      when(() => mockBox.get(ExchangeLocalDataSourceImpl.ratesKey)).thenReturn(jsonStr);

      final result = await localDataSource.getCachedLatestRates();

      expect(result.length, 1);
      expect(result.first.code, 'USD');
      expect(result.first.rateInEgp, 48.5);
      expect(result.first.isFromCache, isTrue);
    });

    test('throws CacheException when no cached rates exist', () async {
      when(() => mockBox.get(ExchangeLocalDataSourceImpl.ratesKey)).thenReturn(null);

      expect(
        () => localDataSource.getCachedLatestRates(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('cacheHistoricalRates & getCachedHistoricalRates', () {
    test('successfully caches historical rates', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await localDataSource.cacheHistoricalRates(
        currencyCode: 'USD',
        points: [testPoint],
      );

      verify(
        () => mockBox.put('${ExchangeLocalDataSourceImpl.historyPrefix}USD', any()),
      ).called(1);
    });

    test('retrieves cached historical rates', () async {
      final jsonStr = jsonEncode([testPoint.toJson()]);
      when(
        () => mockBox.get('${ExchangeLocalDataSourceImpl.historyPrefix}USD'),
      ).thenReturn(jsonStr);

      final result = await localDataSource.getCachedHistoricalRates('USD');

      expect(result.length, 1);
      expect(result.first.rateInEgp, 48.5);
      expect(result.first.date, DateTime(2026, 9, 8));
    });

    test('throws CacheException when no cached history exists', () async {
      when(
        () => mockBox.get('${ExchangeLocalDataSourceImpl.historyPrefix}USD'),
      ).thenReturn(null);

      expect(
        () => localDataSource.getCachedHistoricalRates('USD'),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
