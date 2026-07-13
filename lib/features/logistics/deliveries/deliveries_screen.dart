import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_form_sheet.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_list_tile.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/state/app_state.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  String _filter = 'all';
  bool _isFabVisible = true;

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _openAddSheet(AppState state) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DeliveryFormSheet(appState: state),
    ).then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery logged successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _openEditSheet(AppState state, Delivery delivery) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          DeliveryFormSheet(appState: state, existingDelivery: delivery),
    ).then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _confirmDelete(AppState state, Delivery delivery) async {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Delivery?'),
        content: Text(
          'Delete the delivery record from ${farmer?.name ?? 'Unknown'} '
          'on ${DateFormat('MMM d, y').format(delivery.date)}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await state.deleteDelivery(delivery.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _swipeClassifyWithConfirm(
    AppState state,
    Delivery delivery,
  ) async {
    if (delivery.status != 'pending') return false;

    final farmer = state.farmerById(delivery.farmerSupplierId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Classify as Class B?'),
        content: Text(
          'Mark the delivery from ${farmer?.name ?? 'Unknown'} '
          '(${delivery.volumeLiters.toStringAsFixed(0)} L) as Class B?\n\n'
          'This will affect their payout calculation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Classify as Class B'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await state.classifyDelivery(
        deliveryId: delivery.id,
        classification: 'Class B',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery classified as Class B'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    }
    return false;
  }

  void _openDetailSheet(AppState state, Delivery delivery) {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    final scheme = Theme.of(context).colorScheme;

    final statusCapitalized = delivery.status.isEmpty
        ? ''
        : '${delivery.status[0].toUpperCase()}${delivery.status.substring(1)}';

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delivery Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              // Farmer Info Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person_outline_rounded,
                        color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer?.name ?? 'Unknown Farmer',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Farmer Supplier',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Grid Info
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.8,
                children: [
                  _DetailGridItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: DateFormat('MMM d, y').format(delivery.date),
                  ),
                  _DetailGridItem(
                    icon: Icons.local_drink_rounded,
                    label: 'Volume',
                    value: '${delivery.volumeLiters.toStringAsFixed(1)} L',
                  ),

                  _DetailGridItem(
                    icon: Icons.info_outline_rounded,
                    label: 'Status',
                    value: statusCapitalized,
                    valueColor: delivery.status == 'classified'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF59E0B),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Classification Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (delivery.classification == 'Class A'
                          ? const Color(0xFF16A34A)
                          : delivery.classification == 'Class B'
                              ? const Color(0xFFF59E0B)
                              : scheme.outlineVariant)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      delivery.classification != null
                          ? Icons.verified_rounded
                          : Icons.hourglass_empty_rounded,
                      color: delivery.classification == 'Class A'
                          ? const Color(0xFF16A34A)
                          : delivery.classification == 'Class B'
                              ? const Color(0xFFF59E0B)
                              : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quality Classification',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            delivery.classification ?? 'Pending Review',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: delivery.classification == 'Class A'
                                      ? const Color(0xFF16A34A)
                                      : delivery.classification == 'Class B'
                                          ? const Color(0xFFF59E0B)
                                          : scheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final deliveries = state.deliveries.where((delivery) {
      if (_filter == 'pending') return delivery.status == 'pending';
      if (_filter == 'classified') return delivery.status == 'classified';
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

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
                DropdownMenuItem(
                  value: 'classified',
                  child: Text('Classified'),
                ),
              ],
              onChanged: (value) {
                setState(() => _filter = value ?? 'all');
              },
            ),
          ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isFabVisible) setState(() => _isFabVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isFabVisible) setState(() => _isFabVisible = true);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: state.refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            final listContent = deliveries.isEmpty
                ? const Center(child: Text('No deliveries found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveries[index];
                      final farmer = state.farmerById(
                        delivery.farmerSupplierId,
                      );

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
                          child: const Icon(
                            Icons.done_all,
                            color: Colors.green,
                          ),
                        ),
                        confirmDismiss: (direction) =>
                            _swipeClassifyWithConfirm(state, delivery),
                        child: DeliveryListTile(
                          delivery: delivery,
                          farmer: farmer,
                          onTap: () => _openDetailSheet(state, delivery),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (action) {
                              if (action == 'edit') {
                                _openEditSheet(state, delivery);
                              } else if (action == 'delete') {
                                _confirmDelete(state, delivery);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...[
                            ('all', 'All'),
                            ('pending', 'Pending'),
                            ('classified', 'Classified'),
                          ].map(
                            (pair) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: ChoiceChip(
                                label: Text(pair.$2),
                                selected: _filter == pair.$1,
                                onSelected: (_) =>
                                    setState(() => _filter = pair.$1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: listContent),
                ],
              );
            }
            return listContent;
          },
        ),
      ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () => _openAddSheet(state),
            icon: const Icon(Icons.add),
            label: const Text('Add Delivery'),
          ),
        ),
      ),
    );
  }
}

class _DetailGridItem extends StatelessWidget {
  const _DetailGridItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon,
            size: 20, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
