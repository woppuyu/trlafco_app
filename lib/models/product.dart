/// Represents products that can be produced and sold.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.requiresMilk,
    required this.sellingPrice,
  });

  final String id;
  final String name;
  final String category;
  final bool requiresMilk;
  final double sellingPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'requiresMilk': requiresMilk,
        'sellingPrice': sellingPrice,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      requiresMilk: json['requiresMilk'] as bool,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
    );
  }
}
