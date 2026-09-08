import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/features/exchange/domain/entities/currency_rate.dart';
import 'package:axis_assessment/features/exchange/domain/usecases/get_latest_rates_with_change.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_cubit.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockGetLatestRates extends Mock implements GetLatestRatesWithChange {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetLatestRates usecase;
  late MockNetworkInfo networkInfo;

  setUp(() {
    usecase = MockGetLatestRates();
    networkInfo = MockNetworkInfo();
    when(
      () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<bool>.empty());
  });

  RatesListCubit buildCubit() {
    return RatesListCubit(
      getLatestRatesWithChange: usecase,
      networkInfo: networkInfo,
    );
  }

  blocTest<RatesListCubit, RatesListState>(
    'emits loading then loaded',
    build: () {
      when(() => usecase()).thenAnswer((_) async => Right([sampleRate()]));
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      return buildCubit();
    },
    act: (cubit) => cubit.loadRates(),
    expect: () => [
      const RatesListLoading(),
      isA<RatesListLoaded>().having((state) => state.rates.length, 'len', 1),
    ],
  );

  blocTest<RatesListCubit, RatesListState>(
    'emits empty when the repository returns no rates',
    build: () {
      when(
        () => usecase(),
      ).thenAnswer((_) async => const Right<Failure, List<CurrencyRate>>([]));
      return buildCubit();
    },
    act: (cubit) => cubit.loadRates(),
    expect: () => [const RatesListLoading(), const RatesListEmpty()],
  );

  blocTest<RatesListCubit, RatesListState>(
    'emits error when the usecase fails',
    build: () {
      when(
        () => usecase(),
      ).thenAnswer((_) async => const Left(ServerFailure('boom')));
      return buildCubit();
    },
    act: (cubit) => cubit.loadRates(),
    expect: () => [const RatesListLoading(), const RatesListError('boom')],
  );

  blocTest<RatesListCubit, RatesListState>(
    'marks loaded state as offline when disconnected',
    build: () {
      when(
        () => usecase(),
      ).thenAnswer((_) async => Right([sampleRate(isFromCache: true)]));
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      return buildCubit();
    },
    act: (cubit) => cubit.loadRates(),
    expect: () => [
      const RatesListLoading(),
      isA<RatesListLoaded>().having((state) => state.isOffline, 'offline', true),
    ],
  );
}
