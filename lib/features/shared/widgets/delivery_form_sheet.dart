import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/state/app_state.dart';

/// Bottom-sheet form for adding or editing a Delivery.
///
/// Pass [existingDelivery] to switch the form into edit mode.
class DeliveryFormSheet extends StatefulWidget {
  const DeliveryFormSheet({
    super.key,
    required this.appState,
    this.existingDelivery,
  });

  final AppState appState;

  /// When non-null the form is in "edit" mode, pre-filled with this delivery.
  final Delivery? existingDelivery;

  @override
  State<DeliveryFormSheet> createState() => _DeliveryFormSheetState();
}

class _DeliveryFormSheetState extends State<DeliveryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFarmerId;
  final _volumeController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existingDelivery != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDelivery;
    _selectedFarmerId = existing?.farmerSupplierId;
    _selectedDate = existing?.date ?? DateTime.now();
    _volumeController.text =
        existing != null ? existing.volumeLiters.toStringAsFixed(1) : '';
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 5)),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final volume = double.parse(_volumeController.text.trim());

      if (_isEditing) {
        final updated = widget.existingDelivery!.copyWith(
          farmerSupplierId: _selectedFarmerId!,
          date: _selectedDate,
          volumeLiters: volume,
        );
        await widget.appState.updateDelivery(updated);
      } else {
        final now = DateTime.now().microsecondsSinceEpoch;
        await widget.appState.addDelivery(
          Delivery(
            id: 'DL-$now',
            farmerSupplierId: _selectedFarmerId!,
            date: _selectedDate,
            volumeLiters: volume,
            classification: null,
            status: 'pending',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Delivery' : 'Add Delivery',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('delivery_farmer_dropdown'),
                  initialValue: _selectedFarmerId,
                  decoration: const InputDecoration(labelText: 'Farmer-Supplier'),
                  items: widget.appState.farmers
                      .map(
                        (farmer) => DropdownMenuItem<String>(
                          value: farmer.id,
                          child: Text(farmer.name),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Please choose a farmer-supplier' : null,
                  onChanged: (value) =>
                      setState(() => _selectedFarmerId = value),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Delivery Date',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(DateFormat('MMM d, y').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('delivery_volume_field'),
                  controller: _volumeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Volume (Liters)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Volume is required';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid volume';
                    }
                    if (parsed > 9999) {
                      return 'Volume cannot exceed 9999 L';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('save_delivery_button'),
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
                        : Icon(_isEditing ? Icons.save : Icons.add_task),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : (_isEditing ? 'Save Changes' : 'Save Delivery'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
