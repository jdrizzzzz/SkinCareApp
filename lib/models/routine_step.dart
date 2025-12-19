import 'package:flutter/material.dart';
import '../models/product.dart';

enum RoutineType { morning, night }

// A routine can be reordered and replaced.
class RoutineStep {
  final String id; // stable unique id for ReorderableListView
  final String title; // cleanser ,toner etc.
  final IconData icon;
  final Color cardColor;

  Product? selectedProduct;

  RoutineStep({
    required this.id,
    required this.title,
    required this.icon,
    required this.cardColor,
    this.selectedProduct,
  });
}
