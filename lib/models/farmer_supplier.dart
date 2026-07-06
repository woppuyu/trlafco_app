/// Represents a milk farmer supplier profile.
class FarmerSupplier {
  FarmerSupplier({
    required this.id,
    required this.name,
    required this.barangay,
    required this.contactNumber,
    required this.status,
  });

  final String id;
  final String name;
  final String barangay;
  final String contactNumber;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'barangay': barangay,
        'contactNumber': contactNumber,
        'status': status,
      };

  factory FarmerSupplier.fromJson(Map<String, dynamic> json) {
    return FarmerSupplier(
      id: json['id'] as String,
      name: json['name'] as String,
      barangay: json['barangay'] as String,
      contactNumber: json['contactNumber'] as String,
      status: json['status'] as String,
    );
  }
}
