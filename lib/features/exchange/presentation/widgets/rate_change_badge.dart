import '../../../../core/utils/app_import.dart';

class RateChangeBadge extends StatelessWidget {
  const RateChangeBadge({
    super.key,
    required this.change,
    required this.percent,
    required this.isEgpStrengthened,
  });

  final double change;
  final double percent;
  final bool isEgpStrengthened;

  @override
  Widget build(BuildContext context) {
    final color = isEgpStrengthened ? AppColors.gain : AppColors.loss;
    final prefix = change > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        '$prefix${change.toStringAsFixed(4)}  ($prefix${percent.toStringAsFixed(2)}%)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
