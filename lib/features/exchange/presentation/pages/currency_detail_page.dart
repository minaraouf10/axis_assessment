import '../../../../core/utils/app_import.dart';

class CurrencyDetailPage extends StatelessWidget {
  const CurrencyDetailPage({
    super.key,
    required this.currencyCode,
    this.initialRate,
  });

  final String currencyCode;
  final CurrencyRate? initialRate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CurrencyDetailCubit>()
        ..load(currencyCode: currencyCode, initialRate: initialRate),
      child: CurrencyDetailView(currencyCode: currencyCode),
    );
  }
}

class CurrencyDetailView extends StatelessWidget {
  const CurrencyDetailView({super.key, required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$currencyCode / EGP')),
      body: BlocBuilder<CurrencyDetailCubit, CurrencyDetailState>(
        builder: (context, state) {
          return switch (state) {
            CurrencyDetailInitial() => const LoadingView(
              message: 'Preparing currency details...',
            ),
            CurrencyDetailLoading(:final rate) => Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rate != null) _RateHeader(rate: rate),
                  const SizedBox(height: AppSpacing.xl),
                  const HistoryChartShimmer(),
                ],
              ),
            ),
            CurrencyDetailError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<CurrencyDetailCubit>().load(
                currencyCode: currencyCode,
              ),
            ),
            CurrencyDetailChartError(
              :final rate,
              :final message,
              :final isOffline,
            ) =>
              ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (isOffline) OfflineBanner(lastUpdated: rate.lastUpdated),
                  _RateHeader(rate: rate),
                  const SizedBox(height: AppSpacing.xl),
                  ErrorView(
                    message: message,
                    onRetry: () => context.read<CurrencyDetailCubit>().load(
                          currencyCode: currencyCode,
                          initialRate: rate,
                        ),
                  ),
                ],
              ),
            CurrencyDetailLoaded(:final rate, :final history, :final isOffline) =>
              ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (isOffline) OfflineBanner(lastUpdated: rate.lastUpdated),
                  _RateHeader(rate: rate),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '7-day history',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(child: HistoryLineChart(points: history)),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _RateHeader extends StatelessWidget {
  const _RateHeader({required this.rate});

  final CurrencyRate rate;

  @override
  Widget build(BuildContext context) {
    final rateFormat = NumberFormat.currency(symbol: '', decimalDigits: 4);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Semantics(
      label: 'Rate details for ${rate.name}: ${rateFormat.format(rate.rateInEgp)} EGP',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rate.name, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${rateFormat.format(rate.rateInEgp)} EGP',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            if (rate.hasChange)
              RateChangeBadge(
                change: rate.dailyChange!,
                percent: rate.dailyChangePercent!,
                isEgpStrengthened: rate.isEgpStrengthened,
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Last updated: ${dateFormat.format(rate.lastUpdated.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
