import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

sealed class CurrencyDetailState extends Equatable {
  const CurrencyDetailState();

  @override
  List<Object?> get props => [];
}

class CurrencyDetailInitial extends CurrencyDetailState {
  const CurrencyDetailInitial();
}

class CurrencyDetailLoading extends CurrencyDetailState {
  const CurrencyDetailLoading({this.rate});

  final CurrencyRate? rate;

  @override
  List<Object?> get props => [rate];
}

class CurrencyDetailLoaded extends CurrencyDetailState {
  const CurrencyDetailLoaded({
    required this.rate,
    required this.history,
    this.isOffline = false,
  });

  final CurrencyRate rate;
  final List<HistoricalPoint> history;
  final bool isOffline;

  @override
  List<Object?> get props => [rate, history, isOffline];
}

class CurrencyDetailChartError extends CurrencyDetailState {
  const CurrencyDetailChartError({
    required this.rate,
    required this.message,
    this.isOffline = false,
  });

  final CurrencyRate rate;
  final String message;
  final bool isOffline;

  @override
  List<Object?> get props => [rate, message, isOffline];
}

class CurrencyDetailError extends CurrencyDetailState {
  const CurrencyDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
