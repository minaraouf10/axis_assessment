import 'package:axis_assessment/features/exchange/data/models/currency_rate_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyRateModel.fromInvertedApi', () {
    test('inverts EGP-to-foreign rate correctly', () {
      final model = CurrencyRateModel.fromInvertedApi(
        code: 'USD',
        egpToForeign: 0.02, // 1 EGP = 0.02 USD → 1 USD = 50 EGP
        date: DateTime(2026, 9, 8),
      );

      expect(model.code, 'USD');
      expect(model.name, 'US Dollar');
      expect(model.rateInEgp, closeTo(50.0, 0.01));
      expect(model.dailyChange, isNull);
      expect(model.dailyChangePercent, isNull);
    });

    test('calculates daily change when yesterday rate is provided', () {
      final model = CurrencyRateModel.fromInvertedApi(
        code: 'EUR',
        egpToForeign: 0.01667, // 1 EUR ≈ 59.99 EGP today
        date: DateTime(2026, 9, 8),
        yesterdayEgpToForeign: 0.01695, // 1 EUR ≈ 58.99 EGP yesterday
      );

      expect(model.rateInEgp, closeTo(59.99, 0.1));
      expect(model.dailyChange, isNotNull);
      // Rate went UP (more EGP needed) → EGP weakened → change is positive
      expect(model.dailyChange!, greaterThan(0));
      expect(model.isEgpStrengthened, isFalse);
    });

    test('handles zero rate without crashing', () {
      final model = CurrencyRateModel.fromInvertedApi(
        code: 'JPY',
        egpToForeign: 0,
        date: DateTime(2026, 9, 8),
      );

      expect(model.rateInEgp, 0);
    });

    test('marks EGP as strengthened when rate decreased', () {
      final model = CurrencyRateModel.fromInvertedApi(
        code: 'GBP',
        egpToForeign: 0.0145, // 1 GBP ≈ 68.97 EGP today
        date: DateTime(2026, 9, 8),
        yesterdayEgpToForeign: 0.0140, // 1 GBP ≈ 71.43 EGP yesterday
      );

      // Rate went DOWN (fewer EGP needed) → EGP strengthened → change is negative
      expect(model.dailyChange!, lessThan(0));
      expect(model.isEgpStrengthened, isTrue);
    });
  });
}
