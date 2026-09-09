import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RatesListPage(),
        routes: [
          GoRoute(
            path: 'currency/:code',
            builder: (context, state) {
              final code = state.pathParameters['code'] ?? '';
              final extra = state.extra;
              return CurrencyDetailPage(
                currencyCode: code,
                initialRate: extra is CurrencyRate ? extra : null,
              );
            },
          ),
        ],
      ),
    ],
  );
}
