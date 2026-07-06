import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_form_sheet.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_list_tile.dart';
import 'package:trlafco_app/state/app_state.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final deliveries = state.deliveries.where((delivery) {
      if (_filter == 'pending') return delivery.status == 'pending';
      if (_filter == 'classified') return delivery.status == 'classified';
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: _filter,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'classified', child: Text('Classified')),
              ],
              onChanged: (value) {
                setState(() => _filter = value ?? 'all');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            final delivery = deliveries[index];
            final farmer = state.farmerById(delivery.farmerSupplierId);

            return Dismissible(
              key: Key(delivery.id),
              direction: delivery.status == 'pending'
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.done_all, color: Colors.green),
              ),
              confirmDismiss: (direction) async {
                if (delivery.status != 'pending') {
                  return false;
                }
                await state.classifyDelivery(
                  deliveryId: delivery.id,
                  classification: 'Class B',
                );
                return true;
              },
              child: DeliveryListTile(
                delivery: delivery,
                farmer: farmer,
                onTap: () => context.push('/logistics/deliveries/${delivery.id}'),
              ),
            );
          },
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
        label: const Text('Add Delivery'),
      ),
    );
  }
}

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({
    super.key,
    required this.deliveryId,
  });

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final delivery = state.deliveryById(deliveryId);

    if (delivery == null) {
      return const Scaffold(
        body: Center(child: Text('Delivery not found.')),
      );
    }

    final farmer = state.farmerById(delivery.farmerSupplierId);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer?.name ?? 'Unknown Farmer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('Date: ${delivery.date.toLocal()}'),
                  Text('Volume: ${delivery.volumeLiters.toStringAsFixed(1)} L'),
                  Text('Weight: ${delivery.weightKg.toStringAsFixed(1)} kg'),
                  Text('Status: ${delivery.status}'),
                  Text('Classification: ${delivery.classification ?? 'Pending'}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
