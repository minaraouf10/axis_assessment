import '../../../../core/utils/app_import.dart';

abstract class ExchangeRemoteDataSource {
  Future<List<CurrencyRateModel>> fetchLatestRatesWithChange();

  Future<List<HistoricalPointModel>> fetchHistoricalRates(String currencyCode);
}

class ExchangeRemoteDataSourceImpl implements ExchangeRemoteDataSource {
  ExchangeRemoteDataSourceImpl(this._client, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const String _latestUrl =
      'https://latest.currency-api.pages.dev/v1/currencies/egp.json';

  final DioClient _client;
  final DateTime Function() _clock;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<CurrencyRateModel>> fetchLatestRatesWithChange() async {
    final latest = await _fetchRates(_latestUrl);
    final yesterday = _clock().subtract(const Duration(days: 1));
    Map<String, double> yesterdayRates = const {};
    try {
      yesterdayRates = await _fetchRates(_historicalUrl(yesterday));
    } on ServerException {
      yesterdayRates = const {};
    }

    final date = _clock();
    return SupportedCurrency.all.map((currency) {
      final todayValue = latest[currency.apiKey];
      if (todayValue == null) {
        throw ServerException('Missing rate for ${currency.code}.');
      }
      return CurrencyRateModel.fromInvertedApi(
        code: currency.code,
        egpToForeign: todayValue,
        date: date,
        yesterdayEgpToForeign: yesterdayRates[currency.apiKey],
      );
    }).toList();
  }

  @override
  Future<List<HistoricalPointModel>> fetchHistoricalRates(
    String currencyCode,
  ) async {
    final key = currencyCode.toLowerCase();
    final today = DateTime(_clock().year, _clock().month, _clock().day);
    final dates = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );

    final results = await Future.wait(
      dates.map((date) async {
        try {
          final rates = await _fetchRates(_historicalUrl(date));
          final value = rates[key];
          if (value == null) {
            return null;
          }
          return HistoricalPointModel.fromInvertedApi(
            date: date,
            egpToForeign: value,
          );
        } on ServerException {
          return null;
        }
      }),
    );

    final points = results.whereType<HistoricalPointModel>().toList();

    if (points.isEmpty) {
      throw const ServerException('No historical rates available.');
    }
    return points;
  }

  String _historicalUrl(DateTime date) {
    return 'https://${_dateFormat.format(date)}.currency-api.pages.dev/v1/currencies/egp.json';
  }

  Future<Map<String, double>> _fetchRates(String url) async {
    final json = await _client.getJson(url);
    final egp = json['egp'];
    if (egp is! Map) {
      throw const ServerException('Invalid exchange rate payload.');
    }
    return egp.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as num).toDouble(),
      ),
    );
  }
}
