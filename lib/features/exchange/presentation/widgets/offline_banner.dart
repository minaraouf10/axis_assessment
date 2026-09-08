import '../../../../core/utils/app_import.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(lastUpdated.toLocal());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.offline.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        'Offline · Last updated: $formatted',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
