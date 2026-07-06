import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Logistics Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: wide ? 2 : 1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: wide ? 2.6 : 2.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        title: "Today's Deliveries Logged",
                        value: '${state.todayDeliveriesCount}',
                        icon: Icons.fact_check,
                        color: Colors.teal,
                      ),
                      StatCard(
                        title: 'Pending Classification',
                        value: '${state.pendingDeliveries.length}',
                        icon: Icons.hourglass_top,
                        color: Colors.orange,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• Prioritize pickups in San Isidro and Mabini.'),
                      const Text('• Verify temperature logs before classification.'),
                      const Text('• Update all pending deliveries before 6:00 PM.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => DeliveryFormSheet(appState: state),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick Add Delivery'),
      ),
    );
  }
}
