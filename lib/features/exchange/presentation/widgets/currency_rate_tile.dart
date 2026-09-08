import '../../../../core/utils/app_import.dart';

class CurrencyRateTile extends StatelessWidget {
  const CurrencyRateTile({
    super.key,
    required this.rate,
    this.onTap,
  });

  final CurrencyRate rate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 4);
    return Semantics(
      button: true,
      label: '${rate.code} to Egyptian Pound, rate: ${formatter.format(rate.rateInEgp)} EGP',
      child: AppCard(
        onTap: onTap,
        child: Row(
        children: [
          CircleAvatar(
            child: Text(rate.code.substring(0, 1)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rate.code}/EGP',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  rate.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(rate.rateInEgp),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (rate.hasChange)
                RateChangeBadge(
                  change: rate.dailyChange!,
                  percent: rate.dailyChangePercent!,
                  isEgpStrengthened: rate.isEgpStrengthened,
                )
              else
                Text(
                  'No daily change',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
