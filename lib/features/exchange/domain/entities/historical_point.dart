import '../../../../core/utils/app_import.dart';

class HistoricalPoint extends Equatable {
  const HistoricalPoint({required this.date, required this.rateInEgp});

  final DateTime date;
  final double rateInEgp;

  @override
  List<Object?> get props => [date, rateInEgp];
}
