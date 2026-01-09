import '../models/product.dart';

List<String> extractProductLabels(List<Product> products) {
  return products
      .map((p) => p.label.trim())
      .where((l) => l.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}