import '../../../../core/utils/app_import.dart';

class CurrencyRate extends Equatable {
  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rateInEgp,
    required this.lastUpdated,
    this.dailyChange,
    this.dailyChangePercent,
    this.isFromCache = false,
  });

  final String code;
  final String name;
  /// EGP needed to buy 1 unit of [code].
  final double rateInEgp;
  final DateTime lastUpdated;
  final double? dailyChange;
  final double? dailyChangePercent;
  final bool isFromCache;

  /// EGP strengthened when fewer EGP are needed for 1 foreign unit.
  bool get isEgpStrengthened => (dailyChange ?? 0) < 0;

  bool get hasChange => dailyChange != null && dailyChangePercent != null;

  CurrencyRate copyWith({bool? isFromCache}) {
    return CurrencyRate(
      code: code,
      name: name,
      rateInEgp: rateInEgp,
      lastUpdated: lastUpdated,
      dailyChange: dailyChange,
      dailyChangePercent: dailyChangePercent,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    code,
    name,
    rateInEgp,
    lastUpdated,
    dailyChange,
    dailyChangePercent,
    isFromCache,
  ];
}
