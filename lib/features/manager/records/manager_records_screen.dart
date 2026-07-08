import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        appBar: _RecordsAppBar(),
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

// ─── App bar with title + tab bar ─────────────────────────────────────────────

class _RecordsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _RecordsAppBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text('Records',
          style: Theme.of(context).appBarTheme.titleTextStyle),
      bottom: TabBar(
        labelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
        labelColor: scheme.primary,
        unselectedLabelColor:
            scheme.onSurface.withValues(alpha: 0.5),
        indicatorColor: scheme.primary,
        indicatorWeight: 2,
        dividerColor: scheme.outlineVariant.withValues(alpha: 0.5),
        tabs: const [
          Tab(text: 'Farmers'),
          Tab(text: 'Inventory'),
          Tab(text: 'Payments'),
        ],
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
              mainAxisSpacing: 8,
              childAspectRatio: isWide ? 3.2 : 4.0,
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
            mainAxisSpacing: 8,
            childAspectRatio: isWide ? 2.8 : 3.0,
          ),
          itemCount: state.payments.length,
          itemBuilder: (context, index) {
            final payment = state.payments[index];
            final farmer = state.farmerById(payment.farmerSupplierId);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: payment.status == 'paid'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  child: Icon(
                    payment.status == 'paid'
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: payment.status == 'paid' ? Colors.green : Colors.orange,
                  ),
                ),
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
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Mark as Paid?'),
                              content: const Text(
                                  'Confirm payment release for this record.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
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
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final scheme = Theme.of(context).colorScheme;
    final isActive = farmer.status == 'active';
    final statusColor =
        isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280);

    return Scaffold(
      appBar: AppBar(title: Text(farmer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.agriculture_rounded,
                      size: 26, color: scheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${farmer.barangay}  ·  ${farmer.contactNumber}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    farmer.status,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Recent Deliveries',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '${relatedDeliveries.length} total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (relatedDeliveries.isEmpty)
            Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No deliveries yet.',
                  style: Theme.of(context).textTheme.bodySmall),
            ))
          else
            ...relatedDeliveries.take(8).map(
              (d) {
                final classColor = d.classification == 'Class A'
                    ? const Color(0xFF16A34A)
                    : d.classification == 'Class B'
                        ? const Color(0xFFD97706)
                        : d.classification == 'Rejected'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF6B7280);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMM d, y').format(d.date),
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${d.volumeLiters.toStringAsFixed(0)} L',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: classColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d.classification ?? 'Pending',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: classColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
