/// Represents raw milk deliveries from farmer suppliers.
class Delivery {
  Delivery({
    required this.id,
    required this.farmerSupplierId,
    required this.date,
    required this.volumeLiters,
    required this.classification,
    required this.status,
    this.paymentPeriodStart,
  });

  final String id;
  final String farmerSupplierId;
  final DateTime date;
  final double volumeLiters;
  final String? classification;
  final String status;
  final DateTime? paymentPeriodStart;

  Delivery copyWith({
    String? id,
    String? farmerSupplierId,
    DateTime? date,
    double? volumeLiters,
    String? classification,
    String? status,
    DateTime? paymentPeriodStart,
  }) {
    return Delivery(
      id: id ?? this.id,
      farmerSupplierId: farmerSupplierId ?? this.farmerSupplierId,
      date: date ?? this.date,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      classification: classification ?? this.classification,
      status: status ?? this.status,
      paymentPeriodStart: paymentPeriodStart ?? this.paymentPeriodStart,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerSupplierId': farmerSupplierId,
        'date': date.toIso8601String(),
        'volumeLiters': volumeLiters,
        'classification': classification,
        'status': status,
        'paymentPeriodStart': paymentPeriodStart?.toIso8601String(),
      };

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      farmerSupplierId: json['farmerSupplierId'] as String,
      date: DateTime.parse(json['date'] as String),
      volumeLiters: (json['volumeLiters'] as num).toDouble(),
      classification: json['classification'] as String?,
      status: json['status'] as String,
      paymentPeriodStart: json['paymentPeriodStart'] != null
          ? DateTime.parse(json['paymentPeriodStart'] as String)
          : null,
    );
  }
}
