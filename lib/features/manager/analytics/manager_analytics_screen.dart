import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerAnalyticsScreen extends StatelessWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Header
          Text(
            'Analytics & Forecast',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Supply trends, quality mix, and payout forecast',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),

          // Chart
          _SectionBox(
            title: 'Supply Forecast',
            subtitle: 'Next 30 days (projected)',
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1280),
                        FlSpot(5, 1320),
                        FlSpot(10, 1365),
                        FlSpot(15, 1420),
                        FlSpot(20, 1480),
                        FlSpot(25, 1515),
                        FlSpot(30, 1560),
                      ],
                      isCurved: true,
                      barWidth: 2.5,
                      color: scheme.tertiary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            scheme.tertiary.withValues(alpha: 0.18),
                            scheme.tertiary.withValues(alpha: 0.01),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 10 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Day ${value.toInt()}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: 100,
                        getTitlesWidget: (value, meta) => Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Insights
          Text(
            'Insights',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          const _InsightCard(
            icon: Icons.trending_up_rounded,
            color: Color(0xFF16A34A),
            title: 'Supply Trend',
            text:
                'Milk supply is trending up by an estimated 12%. Consider allocating more volume to Chocolate Milk production this month.',
          ),
          const _InsightCard(
            icon: Icons.verified_rounded,
            color: Color(0xFF0EA5E9),
            title: 'Quality Mix',
            text:
                'Class A deliveries dominate this week. Use this window to build buffer stocks for high-demand dairy SKUs.',
          ),
          const _InsightCard(
            icon: Icons.account_balance_rounded,
            color: Color(0xFF8B5CF6),
            title: 'Payment Timing',
            text:
                'Upcoming payout concentration in the second half of the month may impact cash flow. Prepare staggered release schedules.',
          ),
        ],
      ),
    );
  }
}

// ─── Section box ──────────────────────────────────────────────────────────────

class _SectionBox extends StatelessWidget {
  const _SectionBox({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Insight card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(text,
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.5,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
