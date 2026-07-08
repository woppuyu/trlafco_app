import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';

/// A polished list tile for a single delivery record.
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
    final isPending = delivery.status == 'pending';
    final dateLabel = DateFormat('MMM d, y').format(delivery.date);

    // Classification chip colors
    Color chipColor;
    switch (delivery.classification) {
      case 'Class A':
        chipColor = const Color(0xFF16A34A);
        break;
      case 'Class B':
        chipColor = const Color(0xFFD97706);
        break;
      case 'Rejected':
        chipColor = const Color(0xFFDC2626);
        break;
      default:
        chipColor = const Color(0xFF6B7280);
    }

    final statusColor = isPending
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPending
                        ? Icons.hourglass_top_rounded
                        : Icons.check_circle_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer?.name ?? 'Unknown Farmer',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateLabel  ·  ${delivery.volumeLiters.toStringAsFixed(0)} L  ·  ${delivery.weightKg.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trailing: custom or default chip
                trailing ??
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: chipColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        delivery.classification ?? 'Pending',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: chipColor,
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
