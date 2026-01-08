import '../models/product.dart';
import '../services/product_service.dart';

//Caches the data from product service
class ProductsCache {
  ProductsCache._();
  static final ProductsCache instance = ProductsCache._();

  final ProductService _service = ProductService();

  Future<List<Product>>? _future;
  List<Product>? _last;

  Future<List<Product>> getProducts({int limit = 200}) {
    _future ??= _service.fetchProducts(limit: limit).then((list) {
      _last = list;
      return list;
    });
    return _future!;
  }

  List<Product> get last => _last ?? [];
}