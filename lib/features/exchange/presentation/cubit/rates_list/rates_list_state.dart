import '../../../../../core/utils/app_import.dart';

sealed class RatesListState extends Equatable {
  const RatesListState();

  @override
  List<Object?> get props => [];
}

class RatesListInitial extends RatesListState {
  const RatesListInitial();
}

class RatesListLoading extends RatesListState {
  const RatesListLoading();
}

class RatesListLoaded extends RatesListState {
  const RatesListLoaded({
    required this.rates,
    required this.lastUpdated,
    this.isOffline = false,
  });

  final List<CurrencyRate> rates;
  final DateTime lastUpdated;
  final bool isOffline;

  @override
  List<Object?> get props => [rates, lastUpdated, isOffline];
}

class RatesListEmpty extends RatesListState {
  const RatesListEmpty();
}

class RatesListError extends RatesListState {
  const RatesListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
