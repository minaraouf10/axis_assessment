import '../../../../core/utils/app_import.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  ExchangeRepositoryImpl({
    required ExchangeRemoteDataSource remoteDataSource,
    required ExchangeLocalDataSource localDataSource,
    required this._networkInfo,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final ExchangeRemoteDataSource _remote;
  final ExchangeLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<CurrencyRate>>> getLatestRatesWithChange() async {
    if (await _networkInfo.isConnected) {
      try {
        final rates = await _remote.fetchLatestRatesWithChange();
        await _local.cacheLatestRates(rates);
        return Right(rates);
      } on ServerException catch (error) {
        try {
          final cached = await _local.getCachedLatestRates();
          return Right(cached);
        } on CacheException {
          return Left(ServerFailure(error.message));
        }
      } on CacheException catch (error) {
        return Left(CacheFailure(error.message));
      }
    }

    try {
      final cached = await _local.getCachedLatestRates();
      return Right(cached);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalPoint>>> getHistoricalRates(
    String currencyCode,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final points = await _remote.fetchHistoricalRates(currencyCode);
        await _local.cacheHistoricalRates(
          currencyCode: currencyCode,
          points: points,
        );
        return Right(points);
      } on ServerException catch (error) {
        try {
          final cached = await _local.getCachedHistoricalRates(currencyCode);
          return Right(cached);
        } on CacheException {
          return Left(ServerFailure(error.message));
        }
      } on CacheException catch (error) {
        return Left(CacheFailure(error.message));
      }
    }

    try {
      final cached = await _local.getCachedHistoricalRates(currencyCode);
      return Right(cached);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }
}
