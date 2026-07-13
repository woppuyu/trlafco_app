import 'package:flutter/material.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/state/app_state.dart';

/// Bottom-sheet form for adding or editing a FarmerSupplier.
///
/// Pass [existingFarmer] to switch the form into edit mode.
class FarmerFormSheet extends StatefulWidget {
  const FarmerFormSheet({
    super.key,
    required this.appState,
    this.existingFarmer,
  });

  final AppState appState;

  /// When non-null the form is in "edit" mode, pre-filled with this farmer.
  final FarmerSupplier? existingFarmer;

  @override
  State<FarmerFormSheet> createState() => _FarmerFormSheetState();
}

class _FarmerFormSheetState extends State<FarmerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barangayController;
  late final TextEditingController _contactController;
  late String _status;
  bool _isSaving = false;

  bool get _isEditing => widget.existingFarmer != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingFarmer;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _barangayController =
        TextEditingController(text: existing?.barangay ?? '');
    _contactController =
        TextEditingController(text: existing?.contactNumber ?? '');
    _status = existing?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barangayController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updated = FarmerSupplier(
          id: widget.existingFarmer!.id,
          name: _nameController.text.trim(),
          barangay: _barangayController.text.trim(),
          contactNumber: _contactController.text.trim(),
          status: _status,
        );
        await widget.appState.updateFarmerSupplier(updated);
      } else {
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
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                _isEditing ? 'Edit Farmer-Supplier' : 'Add Farmer-Supplier',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barangayController,
                decoration: const InputDecoration(labelText: 'Barangay'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Barangay is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Contact Number'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact number is required';
                  }
                  final trimmed = value.trim();
                  final phoneRegex = RegExp(r'^(\+63|0)9\d{2}[- ]?\d{3}[- ]?\d{4}$');
                  if (!phoneRegex.hasMatch(trimmed)) {
                    return 'Enter a valid PH mobile number (e.g. 0917-XXX-XXXX)';
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
                  DropdownMenuItem(
                      value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? 'active'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('save_farmer_button'),
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.person_add),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (_isEditing ? 'Save Changes' : 'Save Farmer-Supplier'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
