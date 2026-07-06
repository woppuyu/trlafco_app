/// Represents raw milk deliveries from farmer suppliers.
class Delivery {
  Delivery({
    required this.id,
    required this.farmerSupplierId,
    required this.date,
    required this.volumeLiters,
    required this.weightKg,
    required this.classification,
    required this.status,
  });

  final String id;
  final String farmerSupplierId;
  final DateTime date;
  final double volumeLiters;
  final double weightKg;
  final String? classification;
  final String status;

  Delivery copyWith({
    String? id,
    String? farmerSupplierId,
    DateTime? date,
    double? volumeLiters,
    double? weightKg,
    String? classification,
    String? status,
  }) {
    return Delivery(
      id: id ?? this.id,
      farmerSupplierId: farmerSupplierId ?? this.farmerSupplierId,
      date: date ?? this.date,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      weightKg: weightKg ?? this.weightKg,
      classification: classification ?? this.classification,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerSupplierId': farmerSupplierId,
        'date': date.toIso8601String(),
        'volumeLiters': volumeLiters,
        'weightKg': weightKg,
        'classification': classification,
        'status': status,
      };

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      farmerSupplierId: json['farmerSupplierId'] as String,
      date: DateTime.parse(json['date'] as String),
      volumeLiters: (json['volumeLiters'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      classification: json['classification'] as String?,
      status: json['status'] as String,
    );
  }
}
