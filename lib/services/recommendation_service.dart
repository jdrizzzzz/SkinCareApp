import '../models/product.dart';
import '../models/user_profile.dart';

//Filters products based on user's quiz answers
class RecommendationService {
  const RecommendationService();

  List<Product> filterRecommendedProducts({
    required List<Product> products,
    required UserProfile profile,
  }) {
    return products.where((product) {
      return _isCompatible(product, profile);
    }).toList();
  }

  bool _isCompatible(Product product, UserProfile profile) {
    final normalizedIngredients =
    product.ingredients.map(_normalize).where((i) => i.isNotEmpty).toList();

    for (final allergy in profile.allergies) {
      if (normalizedIngredients.any((i) => i.contains(allergy))) {
        return false;
      }
    }

    for (final condition in profile.conditions) {
      final rule = _conditionRules[condition];
      if (rule == null) continue;
      if (normalizedIngredients.any((i) => rule.excludedIngredients
          .any((exclude) => i.contains(exclude)))) {
        return false;
      }
    }

    if (profile.skinType != null && product.skinTypes.isNotEmpty) {
      final normalizedSkinTypes =
      product.skinTypes.map(_normalize).toSet();
      if (!normalizedSkinTypes.contains(profile.skinType)) {
        return false;
      }
    }

    return true;
  }

  String _normalize(String value) {
    return value.toLowerCase().trim();
  }
}

class IngredientRule {
  final Set<String> excludedIngredients;

  const IngredientRule({required this.excludedIngredients});
}

const Map<String, IngredientRule> _conditionRules = {
  'eczema': IngredientRule(excludedIngredients: {
    'fragrance',
    'parfum',
    'perfume',
    'alcohol denat',
    'sodium lauryl sulfate',
  }),
  'rosacea': IngredientRule(excludedIngredients: {
    'fragrance',
    'parfum',
    'alcohol denat',
    'menthol',
  }),
  'acne': IngredientRule(excludedIngredients: {
    'isopropyl myristate',
    'coconut oil',
  }),
};