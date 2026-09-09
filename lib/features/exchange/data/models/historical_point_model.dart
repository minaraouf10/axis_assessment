import 'package:axis_assessment/features/exchange/data/data.dart';

class HistoricalPointModel extends HistoricalPoint {
  const HistoricalPointModel({required super.date, required super.rateInEgp});

  factory HistoricalPointModel.fromInvertedApi({
    required DateTime date,
    required double egpToForeign,
  }) {
    return HistoricalPointModel(
      date: date,
      rateInEgp: egpToForeign == 0 ? 0 : 1 / egpToForeign,
    );
  }

  factory HistoricalPointModel.fromJson(Map<String, dynamic> json) {
    return HistoricalPointModel(
      date: DateTime.parse(json['date'] as String),
      rateInEgp: (json['rateInEgp'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'rateInEgp': rateInEgp};
  }
}
