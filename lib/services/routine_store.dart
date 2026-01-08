import 'package:flutter/material.dart';

class RoutineStore {
  RoutineStore._();
  static final RoutineStore instance = RoutineStore._();

  // labelKey -> productId
  final ValueNotifier<Map<String, String>> morningSelections =
  ValueNotifier<Map<String, String>>({});

  final ValueNotifier<Map<String, String>> nightSelections =
  ValueNotifier<Map<String, String>>({});

  String _key(String label) => label.trim().toLowerCase();

  // Add/replace a product for this label
  void setMorning({required String label, required String productId}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(morningSelections.value);
    next[labelKey] = productId;
    morningSelections.value = next;
  }

  void setNight({required String label, required String productId}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(nightSelections.value);
    next[labelKey] = productId;
    nightSelections.value = next;
  }

  // Remove whatever is selected for this label
  void removeMorning({required String label}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(morningSelections.value);
    next.remove(labelKey);
    morningSelections.value = next;
  }

  void removeNight({required String label}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(nightSelections.value);
    next.remove(labelKey);
    nightSelections.value = next;
  }

  // Check if THIS label currently points to THIS product
  bool isInMorningForLabel({required String label, required String productId}) {
    final labelKey = _key(label);
    return morningSelections.value[labelKey] == productId;
  }

  bool isInNightForLabel({required String label, required String productId}) {
    final labelKey = _key(label);
    return nightSelections.value[labelKey] == productId;
  }

  // Check if product exists anywhere in that routine
  bool isInMorning(String productId) =>
      morningSelections.value.containsValue(productId);

  bool isInNight(String productId) =>
      nightSelections.value.containsValue(productId);

  String? morningProductForLabel(String label) {
    final labelKey = _key(label);
    return morningSelections.value[labelKey];
  }

  String? nightProductForLabel(String label) {
    final labelKey = _key(label);
    return nightSelections.value[labelKey];
  }
}
