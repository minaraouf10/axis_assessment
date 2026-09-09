import 'package:axis_assessment/core/core.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Unable to fetch exchange rates.']);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'No cached rates available. Connect to the internet.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'You are offline. Connect to the internet and try again.',
  ]);
}
