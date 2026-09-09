import 'package:axis_assessment/core/di/injection_container.dart';
import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

class CurrencyExchangeApp extends StatelessWidget {
  const CurrencyExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Currency Exchange Tracker',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.mode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
