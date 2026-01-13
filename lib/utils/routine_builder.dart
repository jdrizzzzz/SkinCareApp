import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/routine_step.dart';
import '../models/user_profile.dart';

//Generates routine steps based on user's preferences and recommended products (prebuilt or manual)
class RoutineBuilder {
  List<RoutineStep> buildSteps({
    required RoutineType type,
    required UserProfile profile,
    required List<Product> recommendedProducts,
    required bool autoSelectProducts,
    bool includeOnlyRecommended = true,
  }) {
    final steps = <RoutineStep>[];
    final labelMatches = _labelMatches(recommendedProducts);

    void addStepIfAvailable(
        String label,
        IconData icon,
        Color color,
        ) {
      if (includeOnlyRecommended &&
          !labelMatches.contains(label.toLowerCase())) {
        return;
      }
      final selected = autoSelectProducts
          ? _pickFirstMatching(recommendedProducts, label)
          : null;
      steps.add(
        RoutineStep(
          id: '${type.name}_${label.toLowerCase()}',
          title: label,
          icon: icon,
          cardColor: color,
          selectedProduct: selected,
        ),
      );
    }

    if (type == RoutineType.morning) {
      addStepIfAvailable(
        'Cleanser',
        Icons.opacity,
        const Color(0xFFF3D7D7),
      );
      if (!profile.conditions.contains('eczema')) {
        addStepIfAvailable(
          'Toner',
          Icons.water_drop_outlined,
          const Color(0xFFF4DFDF),
        );
      }
      addStepIfAvailable(
        'Serum',
        Icons.bubble_chart_outlined,
        const Color(0xFFF4D2D2),
      );
      addStepIfAvailable(
        'Moisturizer',
        Icons.spa_outlined,
        const Color(0xFFEEDCDC),
      );
      addStepIfAvailable(
        'Sunscreen',
        Icons.wb_sunny_outlined,
        const Color(0xFFF2DADA),
      );
    } else {
      addStepIfAvailable(
        'Cleanser',
        Icons.opacity,
        const Color(0xFFE6E0F2),
      );
      if (profile.conditions.contains('acne') ||
          profile.conditions.contains('rosacea') ||
          profile.goals.contains('anti-aging')) {
        addStepIfAvailable(
          'Treatment',
          Icons.science_outlined,
          const Color(0xFFEDE7F8),
        );
      }
      addStepIfAvailable(
        'Serum',
        Icons.bubble_chart_outlined,
        const Color(0xFFEDE7F8),
      );
      addStepIfAvailable(
        'Moisturizer',
        Icons.spa_outlined,
        const Color(0xFFE6E0F2),
      );
    }

    return steps;
  }

  Set<String> _labelMatches(List<Product> products) {
    return products.map((p) => p.label.toLowerCase().trim()).toSet();
  }

  Product? _pickFirstMatching(List<Product> products, String label) {
    for (final product in products) {
      if (product.label.toLowerCase().trim() == label.toLowerCase().trim()) {
        return product;
      }
    }
    return null;
  }
}