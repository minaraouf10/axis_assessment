import 'package:axis_assessment/core/di/injection_container.dart';
import 'package:axis_assessment/core/widgets/error_view.dart';
import 'package:axis_assessment/core/widgets/loading_view.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/offline_banner.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_cubit.dart';
import 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_state.dart';
import 'package:axis_assessment/features/exchange/presentation/pages/currency_detail_page.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/history_chart_shimmer.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/history_line_chart.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockCurrencyDetailCubit extends MockCubit<CurrencyDetailState>
    implements CurrencyDetailCubit {}

void main() {
  late MockCurrencyDetailCubit mockCubit;

  setUp(() {
    mockCubit = MockCurrencyDetailCubit();

    if (sl.isRegistered<CurrencyDetailCubit>()) {
      sl.unregister<CurrencyDetailCubit>();
    }

    sl.registerFactory<CurrencyDetailCubit>(() => mockCubit);
    when(
      () => mockCubit.load(
        currencyCode: any(named: 'currencyCode'),
        initialRate: any(named: 'initialRate'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    sl.reset();
  });

  Widget buildWidget() {
    return const MaterialApp(home: CurrencyDetailPage(currencyCode: 'USD'));
  }

  testWidgets('renders LoadingView on CurrencyDetailInitial', (tester) async {
    when(() => mockCubit.state).thenReturn(const CurrencyDetailInitial());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('renders HistoryChartShimmer on CurrencyDetailLoading', (
    tester,
  ) async {
    when(() => mockCubit.state)
        .thenReturn(CurrencyDetailLoading(rate: sampleRate()));

    await tester.pumpWidget(buildWidget());

    expect(find.byType(HistoryChartShimmer), findsOneWidget);
  });

  testWidgets('renders HistoryLineChart and details on CurrencyDetailLoaded', (
    tester,
  ) async {
    when(() => mockCubit.state).thenReturn(
      CurrencyDetailLoaded(
        rate: sampleRate(),
        history: sampleHistory(),
        isOffline: false,
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('USD / EGP'), findsOneWidget);
    expect(find.text('7-day history'), findsOneWidget);
    expect(find.byType(HistoryLineChart), findsOneWidget);
  });

  testWidgets(
    'renders rate header and ErrorView with Retry button on CurrencyDetailChartError',
    (tester) async {
      final rate = sampleRate();
      when(() => mockCubit.state).thenReturn(
        CurrencyDetailChartError(
          rate: rate,
          message: 'Could not load historical rates.',
          isOffline: true,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Could not load historical rates.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();

      verify(() => mockCubit.load(currencyCode: 'USD', initialRate: rate))
          .called(1);
    },
  );
}
