import 'package:flutter/material.dart';
import '../models/routine_step.dart';

//Holds user routine choice's in memory
class RoutineStore {
  RoutineStore._();
  static final RoutineStore instance = RoutineStore._();

  final ValueNotifier<List<RoutineStep>> morningSteps =
  ValueNotifier<List<RoutineStep>>([]);

  final ValueNotifier<List<RoutineStep>> nightSteps =
  ValueNotifier<List<RoutineStep>>([]);

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

  void clearMorningSelections() {
    morningSelections.value = {};
  }

  void clearNightSelections() {
    nightSelections.value = {};
  }

  void setMorningSteps(List<RoutineStep> steps) {
    morningSteps.value = List<RoutineStep>.from(steps);
  }

  void setNightSteps(List<RoutineStep> steps) {
    nightSteps.value = List<RoutineStep>.from(steps);
  }

  void addMorningStep(RoutineStep step) {
    final next = List<RoutineStep>.from(morningSteps.value)..add(step);
    morningSteps.value = next;
  }

  void addNightStep(RoutineStep step) {
    final next = List<RoutineStep>.from(nightSteps.value)..add(step);
    nightSteps.value = next;
  }

  void removeMorningStep(String id) {
    final next = List<RoutineStep>.from(morningSteps.value)
      ..removeWhere((step) => step.id == id);
    morningSteps.value = next;
  }

  void removeNightStep(String id) {
    final next = List<RoutineStep>.from(nightSteps.value)
      ..removeWhere((step) => step.id == id);
    nightSteps.value = next;
  }

  void reorderMorningSteps(int oldIndex, int newIndex) {
    final next = List<RoutineStep>.from(morningSteps.value);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    morningSteps.value = next;
  }

  void reorderNightSteps(int oldIndex, int newIndex) {
    final next = List<RoutineStep>.from(nightSteps.value);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    nightSteps.value = next;
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
