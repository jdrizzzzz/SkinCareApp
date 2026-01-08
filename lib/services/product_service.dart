import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

//Reads from firestore
class ProductService {
  final FirebaseFirestore _db;

  ProductService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts({int limit = 50}) async {
    final snapshot = await _db.collection('products').limit(limit).get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
