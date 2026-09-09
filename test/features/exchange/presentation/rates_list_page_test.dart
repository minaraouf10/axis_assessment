import 'package:axis_assessment/core/di/injection_container.dart';
import 'package:axis_assessment/core/theme/cubit/theme_cubit.dart';
import 'package:axis_assessment/core/theme/cubit/theme_state.dart';
import 'package:axis_assessment/core/widgets/error_view.dart';
import 'package:axis_assessment/core/widgets/loading_view.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/offline_banner.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_cubit.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_state.dart';
import 'package:axis_assessment/features/exchange/presentation/pages/rates_list_page.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/currency_rate_tile.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockRatesListCubit extends MockCubit<RatesListState>
    implements RatesListCubit {}

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

void main() {
  late MockRatesListCubit mockRatesListCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockRatesListCubit = MockRatesListCubit();
    mockThemeCubit = MockThemeCubit();

    if (sl.isRegistered<RatesListCubit>()) {
      sl.unregister<RatesListCubit>();
    }
    if (sl.isRegistered<ThemeCubit>()) {
      sl.unregister<ThemeCubit>();
    }

    sl.registerFactory<RatesListCubit>(() => mockRatesListCubit);
    sl.registerLazySingleton<ThemeCubit>(() => mockThemeCubit);

    when(() => mockThemeCubit.state)
        .thenReturn(const ThemeState(mode: ThemeMode.light));
    when(() => mockRatesListCubit.loadRates()).thenAnswer((_) async {});
  });

  tearDown(() {
    sl.reset();
  });

  Widget buildWidget() {
    return BlocProvider<ThemeCubit>.value(
      value: mockThemeCubit,
      child: const MaterialApp(home: RatesListPage()),
    );
  }

  testWidgets('renders LoadingView when state is RatesListLoading', (
    tester,
  ) async {
    when(() => mockRatesListCubit.state).thenReturn(const RatesListLoading());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets(
    'renders currency list and offline banner when state is RatesListLoaded',
    (tester) async {
      final rates = [
        sampleRate(code: 'USD', rate: 48.5),
        sampleRate(code: 'EUR', rate: 52.0),
      ];

      when(() => mockRatesListCubit.state).thenReturn(
        RatesListLoaded(
          rates: rates,
          isOffline: true,
          lastUpdated: DateTime(2026, 9, 8, 12),
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byType(CurrencyRateTile), findsNWidgets(2));
      expect(find.text('USD/EGP'), findsOneWidget);
      expect(find.text('EUR/EGP'), findsOneWidget);
    },
  );

  testWidgets(
    'renders ErrorView with retry button when state is RatesListError and retries on tap',
    (tester) async {
      when(() => mockRatesListCubit.state)
          .thenReturn(const RatesListError('Failed to load rates'));

      await tester.pumpWidget(buildWidget());

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Failed to load rates'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();

      verify(() => mockRatesListCubit.loadRates())
          .called(greaterThanOrEqualTo(1));
    },
  );
}
