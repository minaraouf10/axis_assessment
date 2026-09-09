import 'package:axis_assessment/features/exchange/data/data.dart';
import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();
  final cacheBox = await Hive.openBox<dynamic>('exchange_cache');
  final settingsBox = await Hive.openBox<dynamic>('settings');

  sl
    ..registerLazySingleton<DioClient>(DioClient.new)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(settingsBox))
    ..registerLazySingleton<ExchangeRemoteDataSource>(
      () => ExchangeRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ExchangeLocalDataSource>(
      () => ExchangeLocalDataSourceImpl(cacheBox),
    )
    ..registerLazySingleton<ExchangeRepository>(
      () => ExchangeRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => GetLatestRatesWithChange(sl()))
    ..registerLazySingleton(() => GetHistoricalRates(sl()))
    ..registerFactory(
      () => RatesListCubit(getLatestRatesWithChange: sl(), networkInfo: sl()),
    )
    ..registerFactory(
      () => CurrencyDetailCubit(
        getHistoricalRates: sl(),
        getLatestRatesWithChange: sl(),
        networkInfo: sl(),
      ),
    );
}
