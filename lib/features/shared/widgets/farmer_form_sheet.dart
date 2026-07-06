import 'package:flutter/material.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/state/app_state.dart';

class FarmerFormSheet extends StatefulWidget {
  const FarmerFormSheet({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<FarmerFormSheet> createState() => _FarmerFormSheetState();
}

class _FarmerFormSheetState extends State<FarmerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barangayController = TextEditingController();
  final _contactController = TextEditingController();
  String _status = 'active';

  @override
  void dispose() {
    _nameController.dispose();
    _barangayController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now().microsecondsSinceEpoch;
    await widget.appState.addFarmerSupplier(
      FarmerSupplier(
        id: 'FS-$now',
        name: _nameController.text.trim(),
        barangay: _barangayController.text.trim(),
        contactNumber: _contactController.text.trim(),
        status: _status,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Farmer-Supplier',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barangayController,
                decoration: const InputDecoration(labelText: 'Barangay'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Barangay is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact number is required';
                  }
                  if (value.trim().length < 7) {
                    return 'Enter a valid contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'active'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Farmer-Supplier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
