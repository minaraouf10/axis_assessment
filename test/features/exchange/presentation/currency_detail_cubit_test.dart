import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/features/exchange/domain/entities/currency_rate.dart';
import 'package:axis_assessment/features/exchange/domain/usecases/get_historical_rates.dart';
import 'package:axis_assessment/features/exchange/domain/usecases/get_latest_rates_with_change.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_cubit.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockGetHistoricalRates extends Mock implements GetHistoricalRates {}

class MockGetLatestRates extends Mock implements GetLatestRatesWithChange {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetHistoricalRates history;
  late MockGetLatestRates latest;
  late MockNetworkInfo networkInfo;

  setUp(() {
    history = MockGetHistoricalRates();
    latest = MockGetLatestRates();
    networkInfo = MockNetworkInfo();
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => networkInfo.onConnectivityChanged)
        .thenAnswer((_) => const Stream<bool>.empty());
    when(() => latest()).thenAnswer((_) async => Right([sampleRate()]));
  });

  CurrencyDetailCubit buildCubit() {
    return CurrencyDetailCubit(
      getHistoricalRates: history,
      getLatestRatesWithChange: latest,
      networkInfo: networkInfo,
    );
  }

  blocTest<CurrencyDetailCubit, CurrencyDetailState>(
    'loads rate header and history',
    build: () {
      when(() => history('USD'))
          .thenAnswer((_) async => Right(sampleHistory()));
      return buildCubit();
    },
    act: (cubit) => cubit.load(currencyCode: 'USD', initialRate: sampleRate()),
    expect: () => [
      isA<CurrencyDetailLoading>(),
      isA<CurrencyDetailLoaded>().having(
        (state) => state.history.length,
        'points',
        7,
      ),
    ],
  );

  blocTest<CurrencyDetailCubit, CurrencyDetailState>(
    'keeps the rate and shows a chart error when history fails',
    build: () {
      when(() => history('USD'))
          .thenAnswer((_) async => const Left(ServerFailure('chart down')));
      return buildCubit();
    },
    act: (cubit) => cubit.load(currencyCode: 'USD', initialRate: sampleRate()),
    expect: () => [
      isA<CurrencyDetailLoading>(),
      isA<CurrencyDetailChartError>().having(
        (state) => state.message,
        'message',
        'chart down',
      ),
    ],
  );

  blocTest<CurrencyDetailCubit, CurrencyDetailState>(
    'emits error when the currency cannot be resolved',
    build: () {
      when(
        () => latest(),
      ).thenAnswer((_) async => const Right<Failure, List<CurrencyRate>>([]));
      return buildCubit();
    },
    act: (cubit) => cubit.load(currencyCode: 'USD'),
    expect: () => [
      const CurrencyDetailLoading(),
      const CurrencyDetailError('Currency details are unavailable.'),
    ],
  );

  blocTest<CurrencyDetailCubit, CurrencyDetailState>(
    'prefers the freshly fetched rate over the initialRate passed from the list',
    build: () {
      when(() => latest())
          .thenAnswer((_) async => Right([sampleRate(rate: 50.0)]));
      when(() => history('USD'))
          .thenAnswer((_) async => Right(sampleHistory()));
      return buildCubit();
    },
    act: (cubit) => cubit.load(
      currencyCode: 'USD',
      initialRate: sampleRate(rate: 48.2, isFromCache: true),
    ),
    expect: () => [
      isA<CurrencyDetailLoading>(),
      isA<CurrencyDetailLoaded>().having(
        (state) => state.rate.rateInEgp,
        'rateInEgp',
        50.0,
      ),
    ],
  );

  blocTest<CurrencyDetailCubit, CurrencyDetailState>(
    'falls back to the initialRate when the rates fetch fails',
    build: () {
      when(() => latest())
          .thenAnswer((_) async => const Left(ServerFailure('boom')));
      when(() => history('USD'))
          .thenAnswer((_) async => Right(sampleHistory()));
      return buildCubit();
    },
    act: (cubit) =>
        cubit.load(currencyCode: 'USD', initialRate: sampleRate(rate: 48.2)),
    expect: () => [
      isA<CurrencyDetailLoading>(),
      isA<CurrencyDetailLoaded>().having(
        (state) => state.rate.rateInEgp,
        'rateInEgp',
        48.2,
      ),
    ],
  );
}
