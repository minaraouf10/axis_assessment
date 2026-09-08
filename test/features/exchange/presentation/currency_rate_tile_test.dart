import 'package:axis_assessment/features/exchange/presentation/widgets/currency_rate_tile.dart';
import 'package:axis_assessment/features/exchange/presentation/widgets/rate_change_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  testWidgets('renders green badge when EGP strengthened (rate decreased)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyRateTile(
            rate: sampleRate(change: -0.2, percent: -0.4),
          ),
        ),
      ),
    );

    expect(find.text('USD/EGP'), findsOneWidget);
    expect(find.byType(RateChangeBadge), findsOneWidget);
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RateChangeBadge),
        matching: find.byType(Text),
      ),
    );
    expect(text.style?.color, const Color(0xFF1B8A5A));
  });

  testWidgets('renders red badge when EGP weakened (rate increased)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyRateTile(
            rate: sampleRate(change: 0.3, percent: 0.6),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(RateChangeBadge),
        matching: find.byType(Text),
      ),
    );
    expect(text.style?.color, const Color(0xFFC44536));
  });
}
