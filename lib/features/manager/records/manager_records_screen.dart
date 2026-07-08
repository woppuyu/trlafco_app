import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/state/app_state.dart';

class ManagerRecordsScreen extends StatelessWidget {
  const ManagerRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(text: 'Farmer-Suppliers'),
            Tab(text: 'Inventory'),
            Tab(text: 'Payments'),
          ],
        ),
        body: TabBarView(
          children: [
            _FarmerSuppliersTab(),
            _InventoryTab(),
            _PaymentsTab(),
          ],
        ),
      ),
    );
  }
}

class _FarmerSuppliersTab extends StatelessWidget {
  const _FarmerSuppliersTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return RefreshIndicator(
      onRefresh: state.refreshData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final crossAxisCount = isWide ? 2 : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 0,
              childAspectRatio: isWide ? 3.8 : 5,
            ),
            itemCount: state.farmers.length,
            itemBuilder: (context, index) {
              final farmer = state.farmers[index];
              return Card(
                child: ListTile(
                  onTap: () =>
                      context.push('/manager/records/farmer/${farmer.id}'),
                  title: Text(farmer.name),
                  subtitle:
                      Text('${farmer.barangay} • ${farmer.contactNumber}'),
                  trailing: Chip(label: Text(farmer.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Raw Milk'),
              Tab(text: 'Finished Product'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Class A + B Milk Total'),
                        subtitle: Text(
                          '${state.totalRawMilkStock.toStringAsFixed(0)} liters currently available',
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.inventory.length,
                  itemBuilder: (context, index) {
                    final inv = state.inventory[index];
                    final product = state.products
                        .firstWhere((p) => p.id == inv.productId);
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Stock: ${inv.currentStock} • Reserved: ${inv.reservedStock}',
                        ),
                        trailing: Text('PHP ${product.sellingPrice.toStringAsFixed(0)}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final crossAxisCount = isWide ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            childAspectRatio: isWide ? 3.2 : 4.5,
          ),
          itemCount: state.payments.length,
          itemBuilder: (context, index) {
            final payment = state.payments[index];
            final farmer = state.farmerById(payment.farmerSupplierId);
            return Card(
              child: ListTile(
                title: Text(
                    '${farmer?.name ?? 'Unknown'} • ${payment.periodLabel}'),
                subtitle: Text(
                  '${payment.totalVolumeLiters.toStringAsFixed(0)} L • PHP ${payment.totalAmount.toStringAsFixed(2)}',
                ),
                trailing: payment.status == 'paid'
                    ? const Chip(label: Text('Paid'))
                    : TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Mark as Paid?'),
                              content: const Text(
                                  'Confirm payment release for this record.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await state.markPaymentPaid(payment.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payment marked as paid'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Mark Paid'),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

class FarmerSupplierDetailScreen extends StatelessWidget {
  const FarmerSupplierDetailScreen({
    super.key,
    required this.farmerId,
  });

  final String farmerId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final FarmerSupplier? farmer = state.farmerById(farmerId);

    if (farmer == null) {
      return const Scaffold(
        body: Center(child: Text('Farmer-Supplier not found.')),
      );
    }

    final relatedDeliveries = state.deliveries
        .where((d) => d.farmerSupplierId == farmer.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer-Supplier Detail')),
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
                    farmer.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Barangay: ${farmer.barangay}'),
                  Text('Contact: ${farmer.contactNumber}'),
                  Text('Status: ${farmer.status}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Recent Deliveries',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...relatedDeliveries.take(8).map(
            (d) => Card(
              child: ListTile(
                title: Text(DateFormat('MMM d, y').format(d.date)),
                subtitle: Text(
                  '${d.volumeLiters.toStringAsFixed(0)} L • ${d.classification ?? 'Pending'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
