import '../../../../core/utils/app_import.dart';

class HistoryLineChart extends StatelessWidget {
  const HistoryLineChart({super.key, required this.points});

  final List<HistoricalPoint> points;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].rateInEgp),
    ];
    final values = points.map((point) => point.rateInEgp);
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() < 0.0001
        ? maxY * 0.01
        : (maxY - minY) * 0.2;

    return Semantics(
      label:
          '7-day historical exchange rate chart with ${points.length} data points',
      child: SizedBox(
        height: 240,
        child: Padding(
          padding: const EdgeInsets.only(
            right: AppSpacing.lg,
            top: AppSpacing.md,
          ),
          child: LineChart(
            LineChartData(
              minY: minY - pad,
              maxY: maxY + pad,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.round();
                      final dateLabel = index >= 0 && index < points.length
                          ? DateFormat('MM/dd').format(points[index].date)
                          : '';
                      return LineTooltipItem(
                        '$dateLabel\n${spot.y.toStringAsFixed(2)} EGP',
                        TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MM/dd').format(points[index].date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
