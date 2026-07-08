import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/farmer_form_sheet.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/state/app_state.dart';

class LogisticsFarmerSuppliersScreen extends StatelessWidget {
  const LogisticsFarmerSuppliersScreen({super.key});

  void _openAddSheet(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FarmerFormSheet(appState: state),
    ).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farmer-supplier added'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _openEditSheet(
      BuildContext context, AppState state, FarmerSupplier farmer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          FarmerFormSheet(appState: state, existingFarmer: farmer),
    ).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farmer-supplier updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, AppState state, FarmerSupplier farmer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Farmer-Supplier?'),
        content: Text(
          'Remove ${farmer.name} from ${farmer.barangay}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await state.deleteFarmerSupplier(farmer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${farmer.name} removed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer-Suppliers')),
      body: RefreshIndicator(
        onRefresh: state.refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            final crossAxisCount = isWide ? 2 : 1;

            if (state.farmers.isEmpty) {
              return const Center(child: Text('No farmer-suppliers yet.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 0,
                childAspectRatio: isWide ? 3.5 : 5,
              ),
              itemCount: state.farmers.length,
              itemBuilder: (context, index) {
                final farmer = state.farmers[index];
                return Card(
                  child: ListTile(
                    title: Text(farmer.name),
                    subtitle:
                        Text('${farmer.barangay} • ${farmer.contactNumber}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(label: Text(farmer.status)),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (action) {
                            if (action == 'edit') {
                              _openEditSheet(context, state, farmer);
                            } else if (action == 'delete') {
                              _confirmDelete(context, state, farmer);
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
                                  Icon(Icons.person_remove_outlined,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Remove',
                                      style:
                                          TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, state),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Farmer-Supplier'),
      ),
    );
  }
}
