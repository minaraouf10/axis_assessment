import 'package:axis_assessment/features/exchange/data/data.dart';

class CurrencyRateModel extends CurrencyRate {
  const CurrencyRateModel({
    required super.code,
    required super.name,
    required super.rateInEgp,
    required super.lastUpdated,
    super.dailyChange,
    super.dailyChangePercent,
    super.isFromCache,
  });

  factory CurrencyRateModel.fromInvertedApi({
    required String code,
    required double egpToForeign,
    required DateTime date,
    double? yesterdayEgpToForeign,
    bool isFromCache = false,
  }) {
    final currency = SupportedCurrency.byCode(code);
    final rate = _invert(egpToForeign);
    double? change;
    double? changePercent;
    if (yesterdayEgpToForeign != null) {
      final yesterdayRate = _invert(yesterdayEgpToForeign);
      change = rate - yesterdayRate;
      changePercent = yesterdayRate == 0
          ? null
          : (change / yesterdayRate) * 100;
    }
    return CurrencyRateModel(
      code: currency.code,
      name: currency.name,
      rateInEgp: rate,
      lastUpdated: date,
      dailyChange: change,
      dailyChangePercent: changePercent,
      isFromCache: isFromCache,
    );
  }

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    return CurrencyRateModel(
      code: json['code'] as String,
      name: json['name'] as String,
      rateInEgp: (json['rateInEgp'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      dailyChange: (json['dailyChange'] as num?)?.toDouble(),
      dailyChangePercent: (json['dailyChangePercent'] as num?)?.toDouble(),
      isFromCache: json['isFromCache'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'rateInEgp': rateInEgp,
      'lastUpdated': lastUpdated.toIso8601String(),
      'dailyChange': dailyChange,
      'dailyChangePercent': dailyChangePercent,
      'isFromCache': isFromCache,
    };
  }

  @override
  CurrencyRateModel copyWith({bool? isFromCache}) {
    return CurrencyRateModel(
      code: code,
      name: name,
      rateInEgp: rateInEgp,
      lastUpdated: lastUpdated,
      dailyChange: dailyChange,
      dailyChangePercent: dailyChangePercent,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  static double _invert(double egpToForeign) {
    if (egpToForeign == 0) {
      return 0;
    }
    return 1 / egpToForeign;
  }
}
