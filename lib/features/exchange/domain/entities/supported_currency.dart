import '../../../../core/utils/app_import.dart';

class SupportedCurrency extends Equatable {
  const SupportedCurrency({
    required this.code,
    required this.name,
    required this.flag,
  });

  final String code;
  final String name;
  final String flag;

  static const List<SupportedCurrency> all = [
    SupportedCurrency(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    SupportedCurrency(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    SupportedCurrency(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
    SupportedCurrency(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
    SupportedCurrency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵'),
  ];

  static SupportedCurrency byCode(String code) {
    return all.firstWhere(
      (currency) => currency.code.toUpperCase() == code.toUpperCase(),
      orElse: () => SupportedCurrency(
        code: code.toUpperCase(),
        name: code,
        flag: '💱',
      ),
    );
  }

  String get apiKey => code.toLowerCase();

  @override
  List<Object?> get props => [code, name, flag];
}
