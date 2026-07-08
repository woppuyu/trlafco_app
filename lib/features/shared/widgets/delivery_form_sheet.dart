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
  final _weightController = TextEditingController();
  late DateTime _selectedDate;

  bool get _isEditing => widget.existingDelivery != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDelivery;
    _selectedFarmerId = existing?.farmerSupplierId;
    _selectedDate = existing?.date ?? DateTime.now();
    _volumeController.text =
        existing != null ? existing.volumeLiters.toStringAsFixed(1) : '';
    _weightController.text =
        existing != null ? existing.weightKg.toStringAsFixed(1) : '';
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _weightController.dispose();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final volume = double.parse(_volumeController.text.trim());
    final weight = double.parse(_weightController.text.trim());

    if (_isEditing) {
      final updated = widget.existingDelivery!.copyWith(
        farmerSupplierId: _selectedFarmerId!,
        date: _selectedDate,
        volumeLiters: volume,
        weightKg: weight,
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
          weightKg: weight,
          classification: null,
          status: 'pending',
        ),
      );
    }

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
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('delivery_weight_field'),
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Weight is required';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('save_delivery_button'),
                    onPressed: _save,
                    icon: Icon(_isEditing ? Icons.save : Icons.add_task),
                    label: Text(
                        _isEditing ? 'Save Changes' : 'Save Delivery'),
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
