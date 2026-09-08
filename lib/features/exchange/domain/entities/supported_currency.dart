import '../../../../core/utils/app_import.dart';

class SupportedCurrency extends Equatable {

  final String code;
  final String name;

  static const List<SupportedCurrency> all = [
  ];

  static SupportedCurrency byCode(String code) {
    return all.firstWhere(
      (currency) => currency.code.toUpperCase() == code.toUpperCase(),
    );
  }

  String get apiKey => code.toLowerCase();

  @override
}
