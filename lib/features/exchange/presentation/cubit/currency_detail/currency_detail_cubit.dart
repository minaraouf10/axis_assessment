import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

class CurrencyDetailCubit extends Cubit<CurrencyDetailState> {
  CurrencyDetailCubit({
    required this._getHistoricalRates,
    required this._getLatestRatesWithChange,
    required this._networkInfo,
  }) : super(const CurrencyDetailInitial()) {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _lastCurrencyCode != null) {
        load(currencyCode: _lastCurrencyCode!);
      }
    });
  }

  final GetHistoricalRates _getHistoricalRates;
  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySub;
  String? _lastCurrencyCode;

  Future<void> load({
    required String currencyCode,
    CurrencyRate? initialRate,
  }) async {
    _lastCurrencyCode = currencyCode;

    // Render the passed-in rate immediately so the header is never blank,
    // then always refetch so a cached value is not left on screen.
    emit(CurrencyDetailLoading(rate: initialRate));

    final ratesResult = await _getLatestRatesWithChange();
    final freshRate = ratesResult.fold(
      (_) => null,
      (rates) => _findRate(rates, currencyCode),
    );

    final rate = freshRate ?? initialRate;

    if (rate == null) {
      if (isClosed) return;
      emit(const CurrencyDetailError('Currency details are unavailable.'));
      return;
    }

    final historyResult = await _getHistoricalRates(currencyCode);
    final offline = !await _networkInfo.isConnected;

    if (isClosed) return;

    historyResult.fold(
      (failure) => emit(
        CurrencyDetailChartError(
          rate: rate,
          message: failure.message,
          isOffline: offline,
        ),
      ),
      (history) {
        if (history.isEmpty) {
          emit(
            CurrencyDetailChartError(
              rate: rate,
              message: 'No historical data for this currency.',
              isOffline: offline,
            ),
          );
          return;
        }
        emit(
          CurrencyDetailLoaded(
            rate: rate,
            history: history,
            isOffline: offline,
          ),
        );
      },
    );
  }

  CurrencyRate? _findRate(List<CurrencyRate> rates, String currencyCode) {
    for (final rate in rates) {
      if (rate.code.toUpperCase() == currencyCode.toUpperCase()) {
        return rate;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
