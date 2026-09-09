import 'package:axis_assessment/core/di/injection_container.dart';
import 'package:axis_assessment/features/exchange/presentation/presentation.dart';

class RatesListPage extends StatelessWidget {
  const RatesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RatesListCubit>()..loadRates(),
      child: const _RatesListView(),
    );
  }
}

class _RatesListView extends StatelessWidget {
  const _RatesListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        actions: const [ThemeToggleButton()],
      ),
      body: BlocBuilder<RatesListCubit, RatesListState>(
        builder: (context, state) {
          return switch (state) {
            RatesListInitial() || RatesListLoading() => const LoadingView(),
            RatesListEmpty() => ErrorView(
              message: 'No exchange rates were returned.',
              onRetry: () => context.read<RatesListCubit>().loadRates(),
            ),
            RatesListError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<RatesListCubit>().loadRates(),
            ),
            RatesListLoaded() => RefreshIndicator(
              onRefresh: context.read<RatesListCubit>().refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    'EGP pairs',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Live rates against the Egyptian Pound',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.isOffline)
                    OfflineBanner(lastUpdated: state.lastUpdated),
                  ...state.rates.map(
                    (rate) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CurrencyRateTile(
                        rate: rate,
                        onTap: () =>
                            context.push('/currency/${rate.code}', extra: rate),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
