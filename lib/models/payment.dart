/// Represents payout summaries for farmer suppliers.
class Payment {
  Payment({
    required this.id,
    required this.farmerSupplierId,
    required this.periodLabel,
    required this.totalVolumeLiters,
    required this.totalAmount,
    required this.status,
  });

  final String id;
  final String farmerSupplierId;
  final String periodLabel;
  final double totalVolumeLiters;
  final double totalAmount;
  final String status;

  Payment copyWith({
    String? status,
  }) {
    return Payment(
      id: id,
      farmerSupplierId: farmerSupplierId,
      periodLabel: periodLabel,
      totalVolumeLiters: totalVolumeLiters,
      totalAmount: totalAmount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerSupplierId': farmerSupplierId,
        'periodLabel': periodLabel,
        'totalVolumeLiters': totalVolumeLiters,
        'totalAmount': totalAmount,
        'status': status,
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      farmerSupplierId: json['farmerSupplierId'] as String,
      periodLabel: json['periodLabel'] as String,
      totalVolumeLiters: (json['totalVolumeLiters'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
