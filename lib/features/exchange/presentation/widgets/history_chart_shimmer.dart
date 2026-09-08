import '../../../../core/utils/app_import.dart';

class HistoryChartShimmer extends StatelessWidget {
  const HistoryChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }
}
