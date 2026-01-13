//Define a Product with fields
class Product {
  final String id;
  final String name;
  final String brand;
  final String label; // cleanser / toner / moisturizer / treatment etc.
  final double? price;
  final double? rank;
  final List<String> skinTypes;
  final List<String> ingredients;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.label,
    this.price,
    this.rank,
    required this.skinTypes,
    required this.ingredients,
    this.imageUrl,
  });

  //converts firestore data to product object
  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      label: data['label'] ?? '',
      price: (data['price'] as num?)?.toDouble(),
      rank: (data['rank'] as num?)?.toDouble(),
      skinTypes: List<String>.from(data['skinTypes'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      imageUrl: data['imageUrl'] as String?,
    );
  }
}
