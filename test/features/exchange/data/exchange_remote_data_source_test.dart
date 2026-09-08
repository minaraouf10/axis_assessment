import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/core/network/dio_client.dart';
import 'package:axis_assessment/features/exchange/data/datasources/exchange_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;
  late ExchangeRemoteDataSourceImpl remoteDataSource;
  final fixedDate = DateTime(2026, 9, 8, 12, 0, 0);

  setUp(() {
    mockDioClient = MockDioClient();
    remoteDataSource = ExchangeRemoteDataSourceImpl(
      mockDioClient,
      clock: () => fixedDate,
    );
  });

  group('fetchLatestRatesWithChange', () {
    test('successfully fetches and inverts rates with yesterday change', () async {
      // Supported currencies: USD, EUR, GBP, SAR, JPY
      final latestPayload = {
        'date': '2026-09-08',
        'egp': {
          'usd': 0.02, // 1 USD = 50.0 EGP
          'eur': 0.018, // 1 EUR = 55.55 EGP
          'gbp': 0.015, // 1 GBP = 66.66 EGP
          'sar': 0.075, // 1 SAR = 13.33 EGP
          'jpy': 3.125, // 1 JPY = 0.32 EGP
        },
      };

      final yesterdayPayload = {
        'date': '2026-09-07',
        'egp': {
          'usd': 0.0208333, // yesterday 1 USD = 48.0 EGP
          'eur': 0.018,
          'gbp': 0.015,
          'sar': 0.075,
          'jpy': 3.125,
        },
      };

      when(
        () => mockDioClient.getJson('https://latest.currency-api.pages.dev/v1/currencies/egp.json'),
      ).thenAnswer((_) async => latestPayload);

      when(
        () => mockDioClient.getJson('https://2026-09-07.currency-api.pages.dev/v1/currencies/egp.json'),
      ).thenAnswer((_) async => yesterdayPayload);

      final result = await remoteDataSource.fetchLatestRatesWithChange();

      expect(result.length, 5);
      final usd = result.firstWhere((r) => r.code == 'USD');
      expect(usd.rateInEgp, closeTo(50.0, 0.001));
      expect(usd.dailyChange, isNotNull);
      expect(usd.dailyChangePercent, isNotNull);
    });

    test('handles missing yesterday payload gracefully', () async {
      final latestPayload = {
        'date': '2026-09-08',
        'egp': {
          'usd': 0.02,
          'eur': 0.018,
          'gbp': 0.015,
          'sar': 0.075,
          'jpy': 3.125,
        },
      };

      when(
        () => mockDioClient.getJson('https://latest.currency-api.pages.dev/v1/currencies/egp.json'),
      ).thenAnswer((_) async => latestPayload);

      when(
        () => mockDioClient.getJson('https://2026-09-07.currency-api.pages.dev/v1/currencies/egp.json'),
      ).thenThrow(const ServerException('404 Not Found'));

      final result = await remoteDataSource.fetchLatestRatesWithChange();

      expect(result.length, 5);
      final usd = result.firstWhere((r) => r.code == 'USD');
      expect(usd.rateInEgp, closeTo(50.0, 0.001));
      expect(usd.dailyChange, isNull);
    });

    test('throws ServerException when latest payload is invalid', () async {
      when(
        () => mockDioClient.getJson(any()),
      ).thenAnswer((_) async => {'invalid': 123});

      expect(
        () => remoteDataSource.fetchLatestRatesWithChange(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('fetchHistoricalRates', () {
    test('fetches and returns 7 days of historical points in parallel', () async {
      when(
        () => mockDioClient.getJson(any()),
      ).thenAnswer((invocation) async {
        return {
          'egp': {'usd': 0.02},
        };
      });

      final result = await remoteDataSource.fetchHistoricalRates('USD');

      expect(result.length, 7);
      expect(result.first.rateInEgp, closeTo(50.0, 0.001));
      expect(result.last.rateInEgp, closeTo(50.0, 0.001));
    });

    test('throws ServerException when all historical days fail', () async {
      when(
        () => mockDioClient.getJson(any()),
      ).thenThrow(const ServerException('Network failure'));

      expect(
        () => remoteDataSource.fetchHistoricalRates('USD'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
