import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_list_tile.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/state/app_state.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// Local shadow of the pending list so we can animate removals.
  late List<Delivery> _items;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync on first build only; subsequent updates are driven by _classify().
    if (!_initialized) {
      _items = List<Delivery>.from(
        context.read<AppState>().pendingDeliveries,
      );
      _initialized = true;
    }
  }

  Future<bool> _confirmClassification(String classification, String farmerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          classification == 'Rejected'
              ? 'Reject Delivery?'
              : 'Classify as $classification?',
        ),
        content: Text(
          classification == 'Rejected'
              ? 'Are you sure you want to reject the delivery from $farmerName?'
              : 'Are you sure you want to classify the delivery from $farmerName as $classification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: classification == 'Rejected'
                  ? Theme.of(context).colorScheme.error
                  : null,
              foregroundColor: classification == 'Rejected'
                  ? Theme.of(context).colorScheme.onError
                  : null,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(classification == 'Rejected' ? 'Reject' : 'Confirm'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _classifyPending(
    AppState state,
    Delivery delivery,
    String classification,
  ) async {
    final index = _items.indexWhere((d) => d.id == delivery.id);
    if (index == -1) return;

    // Animate removal before updating state.
    final removed = _items[index];
    _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedTile(removed, animation, state),
      duration: const Duration(milliseconds: 320),
    );

    // Wait for animation to finish, then persist.
    await Future<void>.delayed(const Duration(milliseconds: 160));
    await state.classifyDelivery(
      deliveryId: delivery.id,
      classification: classification,
    );

    if (mounted) {
      final label = classification == 'Rejected' ? 'Rejected ✗' : '$classification ✓';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Classified as $label'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openPendingClassifySheet(AppState state, Delivery delivery) {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? selectedClassification;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Classify Delivery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Delivery Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.local_shipping_rounded,
                            color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer?.name ?? 'Unknown Farmer',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Logged on ${DateFormat('MMM d, y').format(delivery.date)} • ${delivery.volumeLiters.toStringAsFixed(0)} L',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  Text(
                    'Select Classification',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Option Selector Chips/Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ClassificationChoiceChip(
                        label: 'Class A',
                        selected: selectedClassification == 'Class A',
                        selectedColor: Colors.green,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Class A'),
                      ),
                      _ClassificationChoiceChip(
                        label: 'Class B',
                        selected: selectedClassification == 'Class B',
                        selectedColor: Colors.orange,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Class B'),
                      ),
                      _ClassificationChoiceChip(
                        label: 'Rejected',
                        selected: selectedClassification == 'Rejected',
                        selectedColor: Colors.red,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Rejected'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Classify button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: selectedClassification == null
                          ? null
                          : () async {
                              final confirmed = await _confirmClassification(
                                selectedClassification!,
                                farmer?.name ?? 'Unknown Farmer',
                              );
                              if (!confirmed) return;
                              if (!context.mounted) return;
                              Navigator.pop(context); // Close bottom sheet
                              await _classifyPending(state, delivery, selectedClassification!);
                            },
                      child: const Text('Confirm Classification'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRemovedTile(
    Delivery delivery,
    Animation<double> animation,
    AppState state,
  ) {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: DeliveryListTile(
          delivery: delivery,
          farmer: farmer,
        ),
      ),
    );
  }

  Widget _buildActiveTile(
    BuildContext context,
    Delivery delivery,
    Animation<double> animation,
    AppState state,
  ) {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    return SizeTransition(
      sizeFactor: animation,
      child: DeliveryListTile(
        key: ValueKey(delivery.id),
        delivery: delivery,
        farmer: farmer,
        onTap: () => _openPendingClassifySheet(state, delivery),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }

  void _openReclassifySheet(AppState state, Delivery delivery) {
    final farmer = state.farmerById(delivery.farmerSupplierId);
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? selectedClassification = delivery.classification;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Reclassify Delivery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Delivery Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.local_shipping_rounded,
                            color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer?.name ?? 'Unknown Farmer',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Logged on ${DateFormat('MMM d, y').format(delivery.date)} • ${delivery.volumeLiters.toStringAsFixed(0)} L',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  Text(
                    'Select Classification',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Option Selector Chips/Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ClassificationChoiceChip(
                        label: 'Class A',
                        selected: selectedClassification == 'Class A',
                        selectedColor: Colors.green,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Class A'),
                      ),
                      _ClassificationChoiceChip(
                        label: 'Class B',
                        selected: selectedClassification == 'Class B',
                        selectedColor: Colors.orange,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Class B'),
                      ),
                      _ClassificationChoiceChip(
                        label: 'Rejected',
                        selected: selectedClassification == 'Rejected',
                        selectedColor: Colors.red,
                        onTap: () => setModalState(
                            () => selectedClassification = 'Rejected'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Save Changes button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: selectedClassification == delivery.classification
                          ? null // Disable if unchanged
                          : () async {
                              final confirmed = await _confirmClassification(
                                selectedClassification!,
                                farmer?.name ?? 'Unknown Farmer',
                              );
                              if (!confirmed) return;
                              if (!context.mounted) return;
                              Navigator.pop(context); // Close bottom sheet
                              await state.classifyDelivery(
                                deliveryId: delivery.id,
                                classification: selectedClassification!,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Reclassified as $selectedClassification'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stateItems = state.pendingDeliveries;
    final classifiedItems = state.classifiedDeliveries;

    // Keep local list in sync if state updates from another screen
    for (final item in stateItems) {
      if (!_items.any((d) => d.id == item.id)) {
        _items.insert(0, item);
        _listKey.currentState?.insertItem(0);
      }
    }
    for (int i = _items.length - 1; i >= 0; i--) {
      if (!stateItems.any((d) => d.id == _items[i].id)) {
        final removed = _items[i];
        _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) =>
              _buildRemovedTile(removed, animation, state),
          duration: const Duration(milliseconds: 280),
        );
      }
    }

    final pendingView = RefreshIndicator(
      onRefresh: () async {
        await state.refreshData();
        final fresh = state.pendingDeliveries;
        setState(() {
          _items = List<Delivery>.from(fresh);
          _initialized = true;
        });
      },
      child: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 56, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    'All deliveries classified!',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(12),
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) {
                if (index >= _items.length) return const SizedBox.shrink();
                return _buildActiveTile(
                    context, _items[index], animation, state);
              },
            ),
    );

    final historyView = RefreshIndicator(
      onRefresh: state.refreshData,
      child: classifiedItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No classified history yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: classifiedItems.length,
              itemBuilder: (context, index) {
                final delivery = classifiedItems[index];
                final farmer = state.farmerById(delivery.farmerSupplierId);

                Color badgeColor;
                if (delivery.classification == 'Class A') {
                  badgeColor = Colors.green;
                } else if (delivery.classification == 'Class B') {
                  badgeColor = Colors.orange;
                } else {
                  badgeColor = Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _openReclassifySheet(state, delivery),
                    leading: CircleAvatar(
                      backgroundColor: badgeColor.withValues(alpha: 0.1),
                      child: Icon(
                        delivery.classification == 'Rejected'
                            ? Icons.close_rounded
                            : Icons.check_rounded,
                        color: badgeColor,
                      ),
                    ),
                    title: Text(farmer?.name ?? 'Unknown Farmer'),
                    subtitle: Text(
                      '${DateFormat('MMM d, y').format(delivery.date)} • ${delivery.volumeLiters.toStringAsFixed(0)} L',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        delivery.classification ?? 'Unclassified',
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Classification Queue'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            pendingView,
            historyView,
          ],
        ),
      ),
    );
  }
}



class _ClassificationChoiceChip extends StatelessWidget {
  const _ClassificationChoiceChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? selectedColor
                    : Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.5),
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? selectedColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
