import '../models/product.dart';

//Extracts unique product labels from product list - to use for new routine steps
List<String> extractProductLabels(List<Product> products) {
  return products
      .map((p) => p.label.trim())
      .where((l) => l.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}