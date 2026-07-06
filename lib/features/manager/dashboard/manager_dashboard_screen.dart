import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/stat_card.dart';
import 'package:trlafco_app/state/app_state.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: state.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Manager Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 680;
                return GridView.count(
                  crossAxisCount: wide ? 4 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: wide ? 1.5 : 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      title: "Today's Deliveries",
                      value: '${state.todayDeliveriesCount}',
                      icon: Icons.local_shipping,
                      color: Colors.teal,
                    ),
                    StatCard(
                      title: 'Raw Milk Stock',
                      value: '${state.totalRawMilkStock.toStringAsFixed(0)} L',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Pending Orders',
                      value: '${state.pendingOrdersCount}',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Monthly Payout',
                      value: 'PHP ${state.thisMonthPayoutTotal.toStringAsFixed(0)}',
                      icon: Icons.payments,
                      color: Colors.indigo,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milk Supply (Last 7 Days)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1120),
                                FlSpot(1, 1180),
                                FlSpot(2, 1210),
                                FlSpot(3, 1165),
                                FlSpot(4, 1245),
                                FlSpot(5, 1290),
                                FlSpot(6, 1325),
                              ],
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                            ),
                          ],
                          titlesData: const FlTitlesData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.warning_amber),
                      title: Text(
                        '${state.pendingDeliveries.length} deliveries awaiting classification',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule),
                      title: const Text('4 payment records are pending release'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
