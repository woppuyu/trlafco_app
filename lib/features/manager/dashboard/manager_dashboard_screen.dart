import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/stat_card.dart';
import 'package:trlafco_app/state/app_state.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: state.refreshData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            // ── Greeting header ────────────────────────────────────────
            _Greeting(username: state.currentUsername ?? 'Manager'),
            const SizedBox(height: 20),

            // ── KPI Cards ──────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 680;
                return GridView.count(
                  crossAxisCount: wide ? 4 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: wide ? 1.5 : 1.15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      title: "Today's Deliveries",
                      value: '${state.todayDeliveriesCount}',
                      icon: Icons.local_shipping_rounded,
                      color: const Color(0xFF0EA5E9),
                      subtitle: 'incoming today',
                    ),
                    StatCard(
                      title: 'Raw Milk Stock',
                      value:
                          '${state.totalRawMilkStock.toStringAsFixed(0)} L',
                      icon: Icons.local_drink_rounded,
                      color: const Color(0xFF06B6D4),
                      subtitle: 'classified volume',
                    ),
                    StatCard(
                      title: 'Pending Orders',
                      value: '${state.pendingOrdersCount}',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFF59E0B),
                      subtitle: 'reserved stock',
                    ),
                    StatCard(
                      title: 'Monthly Payout',
                      value:
                          '₱${NumberFormat('#,###').format(state.thisMonthPayoutTotal.toInt())}',
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF8B5CF6),
                      subtitle: 'Jul 2026',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Chart ──────────────────────────────────────────────────
            _SectionCard(
              title: 'Milk Supply',
              subtitle: 'Last 7 days',
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: 1000,
                    maxY: 1400,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => scheme.surfaceContainerHighest,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              spot.y.toStringAsFixed(1),
                              TextStyle(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
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
                          FlSpot(0, 1120),
                          FlSpot(1, 1180),
                          FlSpot(2, 1210),
                          FlSpot(3, 1165),
                          FlSpot(4, 1245),
                          FlSpot(5, 1290),
                          FlSpot(6, 1325),
                        ],
                        isCurved: true,
                        color: scheme.primary,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          getDotPainter: (spot, xPercent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: scheme.primary,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary.withValues(alpha: 0.15),
                              scheme.primary.withValues(alpha: 0.01),
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
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            return SideTitleWidget(
                              meta: meta,
                              space: 6,
                              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                              child: Text(
                                days[value.toInt()],
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 100,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              '${(value / 1000).toStringAsFixed(1)}k',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
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
            const SizedBox(height: 14),

            // ── Pending actions ────────────────────────────────────────
            _SectionCard(
              title: 'Pending Actions',
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFF59E0B),
                    label:
                        '${state.pendingDeliveries.length} deliveries awaiting classification',
                    onTap: () => context.go('/manager/records?tab=0'),
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.payments_rounded,
                    color: const Color(0xFF8B5CF6),
                    label:
                        '${state.payments.where((p) => p.status == 'pending').length} payment records pending release',
                    onTap: () => context.go('/manager/records?tab=2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $username',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMM d, y').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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

// ─── Action row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
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
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
