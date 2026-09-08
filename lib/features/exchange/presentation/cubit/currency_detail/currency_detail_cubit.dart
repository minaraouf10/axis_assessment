import '../../../../../core/utils/app_import.dart';

class CurrencyDetailCubit extends Cubit<CurrencyDetailState> {
  CurrencyDetailCubit({
    required this._getHistoricalRates,
    required this._getLatestRatesWithChange,
    required this._networkInfo,
  }) : super(const CurrencyDetailInitial());

  final GetHistoricalRates _getHistoricalRates;
  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final NetworkInfo _networkInfo;

  Future<void> load({
    required String currencyCode,
    CurrencyRate? initialRate,
  }) async {
    emit(CurrencyDetailLoading(rate: initialRate));

    var rate = initialRate;
    if (rate == null) {
      final ratesResult = await _getLatestRatesWithChange();
      rate = ratesResult.fold(
        (_) => null,
        (rates) => rates.cast<CurrencyRate?>().firstWhere(
          (item) => item?.code.toUpperCase() == currencyCode.toUpperCase(),
          orElse: () => null,
        ),
      );
    }

    if (rate == null) {
      emit(const CurrencyDetailError('Currency details are unavailable.'));
      return;
    }

    final historyResult = await _getHistoricalRates(currencyCode);
    final offline = !await _networkInfo.isConnected;
    historyResult.fold(
      (failure) => emit(
        CurrencyDetailChartError(
          rate: rate!,
          message: failure.message,
          isOffline: offline,
        ),
      ),
      (history) {
        if (history.isEmpty) {
          emit(
            CurrencyDetailChartError(
              rate: rate!,
              message: 'No historical data for this currency.',
              isOffline: offline,
            ),
          );
          return;
        }
        emit(
          CurrencyDetailLoaded(
            rate: rate!,
            history: history,
            isOffline: offline,
          ),
        );
      },
    );
  }
}
