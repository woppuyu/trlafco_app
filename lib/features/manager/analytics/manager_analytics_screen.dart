import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ManagerAnalyticsScreen extends StatelessWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Analytics & Forecast',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
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
                        barWidth: 3,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ],
                    titlesData: const FlTitlesData(show: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _InsightCard(
            title: 'Supply Trend',
            text:
                'Milk supply is trending up by an estimated 12%. Consider allocating more volume to Chocolate Milk production this month.',
          ),
          const _InsightCard(
            title: 'Quality Mix',
            text:
                'Class A deliveries dominate this week. Use this window to build buffer stocks for high-demand dairy SKUs.',
          ),
          const _InsightCard(
            title: 'Payment Timing',
            text:
                'Upcoming payout concentration in the second half of the month may impact cash flow. Prepare staggered release schedules.',
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.auto_awesome,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(text),
      ),
    );
  }
}
