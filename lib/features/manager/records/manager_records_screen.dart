import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/state/app_state.dart';

class ManagerRecordsScreen extends StatelessWidget {
  const ManagerRecordsScreen({super.key, this.initialIndex = 0});

  final int? initialIndex;

  @override
  Widget build(BuildContext context) {
    int index = initialIndex ?? 0;
    if (index < 0 || index > 2) index = 0;

    return DefaultTabController(
      key: ValueKey(index),
      length: 3,
      initialIndex: index,
      child: const Scaffold(
        appBar: _RecordsAppBar(),
        body: TabBarView(
          children: [
            _FarmerSuppliersTab(),
            _MilkStockTab(),
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
          Tab(text: 'Milk Stock'),
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
              childAspectRatio: isWide ? 2.6 : 3.0,
            ),
            itemCount: state.farmers.length,
            itemBuilder: (context, index) {
              final farmer = state.farmers[index];
              return Card(
                child: ListTile(
                  onTap: () =>
                      context.push('/manager/records/farmer/${farmer.id}'),
                  title: Text(farmer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer.barangay),
                      Text(farmer.contactNumber),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (farmer.status == 'active'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF6B7280))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      farmer.status,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: farmer.status == 'active'
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab();

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _getLatestDeliveryDate(AppState state, String farmerId) {
    final deliveries = state.deliveries.where((d) => d.farmerSupplierId == farmerId);
    if (deliveries.isEmpty) {
      return DateTime(1970);
    }
    return deliveries.map((d) => d.date).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _searchController.text.trim().toLowerCase();

    final filteredPayments = state.payments.where((payment) {
      final farmer = state.farmerById(payment.farmerSupplierId);
      final name = farmer?.name ?? 'Unknown';
      return name.toLowerCase().contains(query);
    }).toList();

    filteredPayments.sort((a, b) {
      if (a.status != b.status) {
        return a.status == 'pending' ? -1 : 1;
      }
      final dateA = _getLatestDeliveryDate(state, a.farmerSupplierId);
      final dateB = _getLatestDeliveryDate(state, b.farmerSupplierId);
      return dateB.compareTo(dateA);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            key: const Key('payments_search_field'),
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by farmer name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.refreshData,
            child: filteredPayments.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No payment records found',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching for a different farmer name.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 720;
                      final crossAxisCount = isWide ? 2 : 1;
                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: isWide ? 2.8 : 3.0,
                        ),
                        itemCount: filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = filteredPayments[index];
                          final farmer = state.farmerById(payment.farmerSupplierId);
                          return Card(
                            child: InkWell(
                              onTap: () => _showPaymentBreakdown(context, state, payment, farmer),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
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
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            farmer?.name ?? 'Unknown',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            payment.periodLabel,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'PHP ${payment.totalAmount.toStringAsFixed(2)}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${payment.totalVolumeLiters.toStringAsFixed(0)} L',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (payment.status == 'paid'
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFD97706))
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: (payment.status == 'paid'
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFD97706))
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        payment.status == 'paid' ? 'Paid' : 'Pending',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: payment.status == 'paid'
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _showPaymentBreakdown(
    BuildContext context,
    AppState state,
    Payment payment,
    FarmerSupplier? farmer,
  ) {
    final periodStart = payment.periodStart;


    final periodDeliveries = state.deliveries.where((d) {
      if (d.farmerSupplierId != payment.farmerSupplierId) return false;
      final dPeriodStart = d.paymentPeriodStart ??
          DateTime(d.date.year, d.date.month, d.date.day <= 15 ? 1 : 16);
      return dPeriodStart.year == periodStart.year &&
             dPeriodStart.month == periodStart.month &&
             dPeriodStart.day == periodStart.day;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Payout Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farmer?.name ?? 'Unknown Farmer'} • ${payment.periodLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${payment.totalVolumeLiters.toStringAsFixed(1)} L',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total Volume',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.5),
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: scheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          Column(
                            children: [
                              Text(
                                'PHP ${payment.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total Payout',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.5),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Deliveries List',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: periodDeliveries.isEmpty
                          ? Center(
                              child: Text(
                                'No deliveries found for this period.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: periodDeliveries.length,
                              itemBuilder: (context, index) {
                                final d = periodDeliveries[index];
                                final classColor = d.classification == 'Class A'
                                    ? const Color(0xFF16A34A)
                                    : d.classification == 'Class B'
                                        ? const Color(0xFFD97706)
                                        : d.classification == 'Rejected'
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF6B7280);

                                final isAccepted = d.classification == 'Class A' || d.classification == 'Class B';
                                final payout = isAccepted ? d.volumeLiters * 45.0 : 0.0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('EEEE, MMM d').format(d.date),
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${d.volumeLiters.toStringAsFixed(1)} L · PHP ${payout.toStringAsFixed(2)}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
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
                                  ),
                                );
                              },
                            ),
                    ),
                    if (payment.status == 'pending') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          key: const Key('mark_paid_from_sheet_button'),
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
                                Navigator.pop(context); // Close bottom sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment marked as paid'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Mark as Paid'),
                        ),
                      ),
                    ],
                  ],
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
                        farmer.barangay,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmer.contactNumber,
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

class _MilkStockTab extends StatelessWidget {
  const _MilkStockTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return RefreshIndicator(
      onRefresh: state.refreshData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.warehouse_rounded, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(
                '${state.totalRawMilkStock.toStringAsFixed(0)} L',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: const Text('Total Raw Milk Stock'),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF16A34A)),
              ),
              title: Text(
                '${state.classARawMilkStock.toStringAsFixed(0)} L',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: const Text('Class A Milk Total'),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: const Icon(Icons.pending_actions_rounded, color: Colors.orange),
              ),
              title: Text(
                '${state.classBRawMilkStock.toStringAsFixed(0)} L',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: const Text('Class B Milk Total'),
            ),
          ),
        ],
      ),
    );
  }
}
