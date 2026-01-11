import '../models/product.dart';

//Cache that hold the recommended products
class RecommendationStore {
  RecommendationStore._();
  static final RecommendationStore instance = RecommendationStore._();

  List<Product> _recommended = [];
  bool _hasRecommendations = false;

  List<Product> get recommended => _recommended;

  bool get hasRecommendations => _hasRecommendations;

  void setRecommendations(List<Product> products) {
    _recommended = List<Product>.from(products);
    _hasRecommendations = true;
  }

  void clear() {
    _recommended = [];
    _hasRecommendations = false;
  }
}