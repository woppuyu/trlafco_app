/// Tracks stocks for finished products.
class FinishedProductInventory {
  FinishedProductInventory({
    required this.productId,
    required this.currentStock,
    required this.reservedStock,
  });

  final String productId;
  final int currentStock;
  final int reservedStock;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'currentStock': currentStock,
        'reservedStock': reservedStock,
      };

  factory FinishedProductInventory.fromJson(Map<String, dynamic> json) {
    return FinishedProductInventory(
      productId: json['productId'] as String,
      currentStock: json['currentStock'] as int,
      reservedStock: json['reservedStock'] as int,
    );
  }
}
