import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

class RatesListCubit extends Cubit<RatesListState> {
  RatesListCubit({
    required this._getLatestRatesWithChange,
    required this._networkInfo,
  }) : super(const RatesListInitial()) {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        loadRates(showLoading: state is! RatesListLoaded);
      }
    });
  }

  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySub;

  Future<void> loadRates({bool showLoading = true}) async {
    if (showLoading) {
      emit(const RatesListLoading());
    }
    final result = await _getLatestRatesWithChange();
    if (isClosed) return;

    await result.fold(
      (failure) async => emit(RatesListError(failure.message)),
      (rates) async {
        if (rates.isEmpty) {
          emit(const RatesListEmpty());
          return;
        }
        final offline = !await _networkInfo.isConnected;
        if (isClosed) return;
        emit(
          RatesListLoaded(
            rates: rates,
            lastUpdated: rates.first.lastUpdated,
            isOffline: offline || rates.any((rate) => rate.isFromCache),
          ),
        );
      },
    );
  }

  Future<void> refresh() => loadRates(showLoading: false);

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
