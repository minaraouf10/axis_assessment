import 'package:axis_assessment/features/exchange/domain/entities/currency_rate.dart';
import 'package:axis_assessment/features/exchange/domain/entities/historical_point.dart';

CurrencyRate sampleRate({
  String code = 'USD',
  double rate = 48.2,
  double? change = -0.12,
  double? percent = -0.25,
  bool isFromCache = false,
  DateTime? lastUpdated,
}) {
  return CurrencyRate(
    code: code,
    name: code == 'USD' ? 'US Dollar' : code,
    rateInEgp: rate,
    lastUpdated: lastUpdated ?? DateTime(2026, 9, 8, 12),
    dailyChange: change,
    dailyChangePercent: percent,
    isFromCache: isFromCache,
  );
}

List<HistoricalPoint> sampleHistory() {
  return List.generate(
    7,
    (index) => HistoricalPoint(
      date: DateTime(2026, 9, 2).add(Duration(days: index)),
      rateInEgp: 48 + index * 0.05,
    ),
  );
}
