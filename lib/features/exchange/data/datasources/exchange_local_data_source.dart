import '../../../../core/utils/app_import.dart';

abstract class ExchangeLocalDataSource {
  Future<void> cacheLatestRates(List<CurrencyRateModel> rates);

  Future<List<CurrencyRateModel>> getCachedLatestRates();

  Future<void> cacheHistoricalRates({
    required String currencyCode,
    required List<HistoricalPointModel> points,
  });

  Future<List<HistoricalPointModel>> getCachedHistoricalRates(
    String currencyCode,
  );
}

class ExchangeLocalDataSourceImpl implements ExchangeLocalDataSource {
  ExchangeLocalDataSourceImpl(this._box);

  static const String ratesKey = 'latest_rates';
  static const String historyPrefix = 'history_';

  final Box<dynamic> _box;

  @override
  Future<void> cacheLatestRates(List<CurrencyRateModel> rates) async {
    try {
      final payload = jsonEncode(rates.map((rate) => rate.toJson()).toList());
      await _box.put(ratesKey, payload);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<List<CurrencyRateModel>> getCachedLatestRates() async {
    try {
      final raw = _box.get(ratesKey) as String?;
      if (raw == null) {
        throw const CacheException('No cached rates found.');
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => CurrencyRateModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).copyWith(isFromCache: true),
          )
          .toList();
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> cacheHistoricalRates({
    required String currencyCode,
    required List<HistoricalPointModel> points,
  }) async {
    try {
      final payload = jsonEncode(points.map((point) => point.toJson()).toList());
      await _box.put('$historyPrefix${currencyCode.toUpperCase()}', payload);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<List<HistoricalPointModel>> getCachedHistoricalRates(
    String currencyCode,
  ) async {
    try {
      final raw = _box.get('$historyPrefix${currencyCode.toUpperCase()}') as String?;
      if (raw == null) {
        throw const CacheException('No cached history found.');
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => HistoricalPointModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException(error.toString());
    }
  }
}
