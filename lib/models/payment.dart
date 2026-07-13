/// Represents payout summaries for farmer suppliers.
class Payment {
  Payment({
    required this.id,
    required this.farmerSupplierId,
    required this.periodLabel,
    required this.periodStart,
    required this.totalVolumeLiters,
    required this.totalAmount,
    required this.status,
    this.deliveryId,
  });

  final String id;
  final String farmerSupplierId;
  final String periodLabel;

  /// The first day of the payment period. Used for reliable month/year filtering.
  final DateTime periodStart;
  final double totalVolumeLiters;
  final double totalAmount;
  final String status;
  final String? deliveryId;

  Payment copyWith({
    String? status,
  }) {
    return Payment(
      id: id,
      farmerSupplierId: farmerSupplierId,
      periodLabel: periodLabel,
      periodStart: periodStart,
      totalVolumeLiters: totalVolumeLiters,
      totalAmount: totalAmount,
      status: status ?? this.status,
      deliveryId: deliveryId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerSupplierId': farmerSupplierId,
        'periodLabel': periodLabel,
        'periodStart': periodStart.toIso8601String(),
        'totalVolumeLiters': totalVolumeLiters,
        'totalAmount': totalAmount,
        'status': status,
        'deliveryId': deliveryId,
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Safe migration: if periodStart is absent (old data), default to DateTime.now()
    // so existing records don't crash. They will be re-seeded on next fresh install.
    DateTime parsedPeriodStart;
    try {
      parsedPeriodStart = json['periodStart'] != null
          ? DateTime.parse(json['periodStart'] as String)
          : DateTime.now();
    } catch (_) {
      parsedPeriodStart = DateTime.now();
    }

    return Payment(
      id: json['id'] as String,
      farmerSupplierId: json['farmerSupplierId'] as String,
      periodLabel: json['periodLabel'] as String,
      periodStart: parsedPeriodStart,
      totalVolumeLiters: (json['totalVolumeLiters'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      deliveryId: json['deliveryId'] as String?,
    );
  }
}
