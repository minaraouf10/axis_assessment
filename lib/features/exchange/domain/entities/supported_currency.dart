import '../../../../core/utils/app_import.dart';

class SupportedCurrency extends Equatable {
  const SupportedCurrency({required this.code, required this.name});

  final String code;
  final String name;

  static const List<SupportedCurrency> all = [
    SupportedCurrency(code: 'USD', name: 'US Dollar'),
    SupportedCurrency(code: 'EUR', name: 'Euro'),
    SupportedCurrency(code: 'GBP', name: 'British Pound'),
    SupportedCurrency(code: 'SAR', name: 'Saudi Riyal'),
    SupportedCurrency(code: 'JPY', name: 'Japanese Yen'),
  ];

  static SupportedCurrency byCode(String code) {
    return all.firstWhere(
      (currency) => currency.code.toUpperCase() == code.toUpperCase(),
      orElse: () => SupportedCurrency(code: code.toUpperCase(), name: code),
    );
  }

  String get apiKey => code.toLowerCase();

  @override
  List<Object?> get props => [code, name];
}
