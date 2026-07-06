import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_list_tile.dart';
import 'package:trlafco_app/state/app_state.dart';

class ClassificationScreen extends StatelessWidget {
  const ClassificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingDeliveries;

    return Scaffold(
      appBar: AppBar(title: const Text('Classification Queue')),
      body: RefreshIndicator(
        onRefresh: state.refreshData,
        child: pending.isEmpty
            ? const Center(child: Text('No pending deliveries.'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pending.length,
                itemBuilder: (context, index) {
                  final delivery = pending[index];
                  final farmer = state.farmerById(delivery.farmerSupplierId);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: DeliveryListTile(
                      key: ValueKey(delivery.id),
                      delivery: delivery,
                      farmer: farmer,
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          _ClassifyActionButton(
                            label: 'A',
                            color: Colors.green,
                            onPressed: () => state.classifyDelivery(
                              deliveryId: delivery.id,
                              classification: 'Class A',
                            ),
                          ),
                          _ClassifyActionButton(
                            label: 'B',
                            color: Colors.orange,
                            onPressed: () => state.classifyDelivery(
                              deliveryId: delivery.id,
                              classification: 'Class B',
                            ),
                          ),
                          _ClassifyActionButton(
                            label: 'R',
                            color: Colors.red,
                            onPressed: () => state.classifyDelivery(
                              deliveryId: delivery.id,
                              classification: 'Rejected',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ClassifyActionButton extends StatelessWidget {
  const _ClassifyActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
