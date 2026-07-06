import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';

class DeliveryListTile extends StatelessWidget {
  const DeliveryListTile({
    super.key,
    required this.delivery,
    required this.farmer,
    this.onTap,
    this.trailing,
  });

  final Delivery delivery;
  final FarmerSupplier? farmer;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, y').format(delivery.date);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(farmer?.name ?? 'Unknown Farmer'),
        subtitle: Text(
          '$dateLabel • ${delivery.volumeLiters.toStringAsFixed(0)} L • ${delivery.weightKg.toStringAsFixed(0)} kg',
        ),
        leading: CircleAvatar(
          backgroundColor: delivery.status == 'pending'
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
          child: Icon(
            delivery.status == 'pending' ? Icons.timelapse : Icons.check,
            color: delivery.status == 'pending' ? Colors.orange : Colors.green,
          ),
        ),
        trailing: trailing ??
            Chip(
              label: Text(delivery.classification ?? 'Pending'),
            ),
      ),
    );
  }
}
