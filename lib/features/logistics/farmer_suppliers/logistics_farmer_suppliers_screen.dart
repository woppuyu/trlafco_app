import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/shared/widgets/farmer_form_sheet.dart';
import 'package:trlafco_app/state/app_state.dart';

class LogisticsFarmerSuppliersScreen extends StatelessWidget {
  const LogisticsFarmerSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer-Suppliers')),
      body: RefreshIndicator(
        onRefresh: state.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.farmers.length,
          itemBuilder: (context, index) {
            final farmer = state.farmers[index];
            return Card(
              child: ListTile(
                title: Text(farmer.name),
                subtitle: Text('${farmer.barangay} • ${farmer.contactNumber}'),
                trailing: Chip(label: Text(farmer.status)),
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
            builder: (_) => FarmerFormSheet(appState: state),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Farmer-Supplier'),
      ),
    );
  }
}
