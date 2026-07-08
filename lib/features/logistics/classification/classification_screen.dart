import 'package:flutter/material.dart';
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

  Future<void> _classify(
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
        trailing: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 160;
            return Wrap(
              spacing: isWide ? 8 : 4,
              children: [
                _ClassifyActionButton(
                  label: 'A',
                  color: Colors.green,
                  onPressed: () => _classify(state, delivery, 'Class A'),
                ),
                _ClassifyActionButton(
                  label: 'B',
                  color: Colors.orange,
                  onPressed: () => _classify(state, delivery, 'Class B'),
                ),
                _ClassifyActionButton(
                  label: 'R',
                  color: Colors.red,
                  onPressed: () => _classify(state, delivery, 'Rejected'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep local list in sync if state updates from another screen
    // (e.g. swipe-classify on Deliveries screen).
    final state = context.watch<AppState>();
    final stateItems = state.pendingDeliveries;
    // Add any newly added pending items that aren't in _items yet.
    for (final item in stateItems) {
      if (!_items.any((d) => d.id == item.id)) {
        _items.insert(0, item);
        _listKey.currentState?.insertItem(0);
      }
    }
    // Remove any items that were classified elsewhere.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification Queue'),
        actions: [
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${_items.length} pending'),
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await state.refreshData();
          // Re-sync local list after pull-to-refresh.
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
