import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_form_sheet.dart';
import 'package:trlafco_app/features/shared/widgets/stat_card.dart';
import 'package:trlafco_app/state/app_state.dart';

class LogisticsDashboardScreen extends StatelessWidget {
  const LogisticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: state.refreshData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              // ── Greeting header ──────────────────────────────────────
              _LogisticsGreeting(username: state.currentUsername ?? 'Staff'),
              const SizedBox(height: 20),

              // ── KPI Cards ────────────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: wide ? 2.6 : 1.15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        title: "Today's Deliveries",
                        value: '${state.todayDeliveriesCount}',
                        icon: Icons.fact_check_rounded,
                        color: const Color(0xFF0EA5E9),
                        subtitle: 'logged today',
                      ),
                      StatCard(
                        title: 'Pending Classification',
                        value: '${state.pendingDeliveries.length}',
                        icon: Icons.hourglass_top_rounded,
                        color: const Color(0xFFF59E0B),
                        subtitle: 'awaiting review',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Quick stats row ──────────────────────────────────────
              _QuickStatsRow(state: state),
              const SizedBox(height: 20),

              // ── Shift notes ──────────────────────────────────────────
              const _ShiftNotesCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => DeliveryFormSheet(appState: state),
          ).then((result) {
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery logged successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Quick Add'),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _LogisticsGreeting extends StatelessWidget {
  const _LogisticsGreeting({required this.username});
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
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_shipping_rounded,
              size: 20, color: Color(0xFF0EA5E9)),
        ),
      ],
    );
  }
}

// ─── Quick stats row ──────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final classifiedCount = state.deliveries
        .where((d) => d.status == 'classified')
        .length;
    final classACount = state.deliveries
        .where((d) => d.classification == 'Class A')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                  label: 'Classified',
                  value: '$classifiedCount',
                  color: const Color(0xFF16A34A)),
              _MiniStat(
                  label: 'Class A',
                  value: '$classACount',
                  color: const Color(0xFF0EA5E9)),
              _MiniStat(
                  label: 'Total Farmers',
                  value: '${state.farmers.length}',
                  color: const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ─── Shift notes ──────────────────────────────────────────────────────────────

class _ShiftNotesCard extends StatelessWidget {
  const _ShiftNotesCard();

  final List<(IconData, String)> _notes = const [
    (Icons.place_rounded, 'Prioritize pickups in San Isidro and Mabini'),
    (Icons.thermostat_rounded,
        'Verify temperature logs before classification'),
    (Icons.schedule_rounded, 'Update all pending deliveries before 6:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.sticky_note_2_rounded,
                    size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text('Shift Notes',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_notes.length, (i) {
            final (icon, text) = _notes[i];
            return Column(
              children: [
                if (i != 0)
                  Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: scheme.outlineVariant.withValues(alpha: 0.4)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: 15,
                          color: scheme.onSurface.withValues(alpha: 0.45)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(text,
                              style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
