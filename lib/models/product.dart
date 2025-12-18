class Product {
  final String id;
  final String name;
  final String brand;
  final double? price;
  final double? rank;
  final List<String> skinTypes;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    this.price,
    this.rank,
    required this.skinTypes,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] as num?)?.toDouble(),
      rank: (data['rank'] as num?)?.toDouble(),
      skinTypes: List<String>.from(data['skinTypes'] ?? []),
    );
  }
}
