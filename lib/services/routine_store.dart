import 'package:flutter/material.dart';
import '../models/routine_step.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Holds user routine choice's in memory
class RoutineStore {
  RoutineStore._();
  static final RoutineStore instance = RoutineStore._();
  static const _morningStepsKey = 'routine.morning.steps';
  static const _nightStepsKey = 'routine.night.steps';
  static const _morningSelectionsKey = 'routine.morning.selections';
  static const _nightSelectionsKey = 'routine.night.selections';

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

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final morningStepsJson = prefs.getString(_morningStepsKey);
    final nightStepsJson = prefs.getString(_nightStepsKey);
    final morningSelectionsJson = prefs.getString(_morningSelectionsKey);
    final nightSelectionsJson = prefs.getString(_nightSelectionsKey);

    if (morningStepsJson != null) {
      final decoded = jsonDecode(morningStepsJson);
      if (decoded is List) {
        morningSteps.value =
            decoded.map((item) => _stepFromJson(item)).toList();
      }
    }

    if (nightStepsJson != null) {
      final decoded = jsonDecode(nightStepsJson);
      if (decoded is List) {
        nightSteps.value = decoded.map((item) => _stepFromJson(item)).toList();
      }
    }

    if (morningSelectionsJson != null) {
      final decoded = jsonDecode(morningSelectionsJson);
      if (decoded is Map<String, dynamic>) {
        morningSelections.value = decoded.map(
              (key, value) => MapEntry(key, value.toString()),
        );
      }
    }

    if (nightSelectionsJson != null) {
      final decoded = jsonDecode(nightSelectionsJson);
      if (decoded is Map<String, dynamic>) {
        nightSelections.value = decoded.map(
              (key, value) => MapEntry(key, value.toString()),
        );
      }
    }
  }

  Map<String, dynamic> _stepToJson(RoutineStep step) => {
    'id': step.id,
    'title': step.title,
    'iconCodePoint': step.icon.codePoint,
    'iconFontFamily': step.icon.fontFamily,
    'iconFontPackage': step.icon.fontPackage,
    'cardColor': step.cardColor.value,
  };

  RoutineStep _stepFromJson(dynamic data) {
    if (data is! Map) {
      return RoutineStep(
        id: 'unknown',
        title: 'Unknown',
        icon: Icons.add_circle_outline,
        cardColor: const Color(0xFFF3D7D7),
      );
    }
    final map = Map<String, dynamic>.from(data as Map);
    return RoutineStep(
      id: map['id']?.toString() ?? 'unknown',
      title: map['title']?.toString() ?? 'Unknown',
      icon: IconData(
        map['iconCodePoint'] as int? ?? Icons.add_circle_outline.codePoint,
        fontFamily:
        map['iconFontFamily'] as String? ?? Icons.add_circle_outline.fontFamily,
        fontPackage: map['iconFontPackage'] as String?,
      ),
      cardColor: Color(map['cardColor'] as int? ?? 0xFFF3D7D7),
    );
  }

  void _persistSteps() {
    unawaited(_saveSteps());
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _morningStepsKey,
      jsonEncode(morningSteps.value.map(_stepToJson).toList()),
    );
    await prefs.setString(
      _nightStepsKey,
      jsonEncode(nightSteps.value.map(_stepToJson).toList()),
    );
  }

  void _persistSelections() {
    unawaited(_saveSelections());
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _morningSelectionsKey,
      jsonEncode(morningSelections.value),
    );
    await prefs.setString(
      _nightSelectionsKey,
      jsonEncode(nightSelections.value),
    );
  }

  // Add/replace a product for this label
  void setMorning({required String label, required String productId}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(morningSelections.value);
    next[labelKey] = productId;
    morningSelections.value = next;
    _persistSelections();
  }

  void setNight({required String label, required String productId}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(nightSelections.value);
    next[labelKey] = productId;
    nightSelections.value = next;
    _persistSelections();
  }

  // Remove whatever is selected for this label
  void removeMorning({required String label}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(morningSelections.value);
    next.remove(labelKey);
    morningSelections.value = next;
    _persistSelections();
  }

  void removeNight({required String label}) {
    final labelKey = _key(label);
    final next = Map<String, String>.from(nightSelections.value);
    next.remove(labelKey);
    nightSelections.value = next;
    _persistSelections();
  }

  void clearMorningSelections() {
    morningSelections.value = {};
  }

  void clearNightSelections() {
    nightSelections.value = {};
    _persistSelections();
  }

  void setMorningSteps(List<RoutineStep> steps) {
    morningSteps.value = List<RoutineStep>.from(steps);
    _persistSteps();
  }

  void setNightSteps(List<RoutineStep> steps) {
    nightSteps.value = List<RoutineStep>.from(steps);
    _persistSteps();
  }

  void addMorningStep(RoutineStep step) {
    final next = List<RoutineStep>.from(morningSteps.value)..add(step);
    morningSteps.value = next;
    _persistSteps();
  }

  void addNightStep(RoutineStep step) {
    final next = List<RoutineStep>.from(nightSteps.value)..add(step);
    nightSteps.value = next;
    _persistSteps();
  }

  void removeMorningStep(String id) {
    final next = List<RoutineStep>.from(morningSteps.value)
      ..removeWhere((step) => step.id == id);
    morningSteps.value = next;
    _persistSteps();
  }

  void removeNightStep(String id) {
    final next = List<RoutineStep>.from(nightSteps.value)
      ..removeWhere((step) => step.id == id);
    nightSteps.value = next;
    _persistSteps();
  }

  void reorderMorningSteps(int oldIndex, int newIndex) {
    final next = List<RoutineStep>.from(morningSteps.value);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    morningSteps.value = next;
    _persistSteps();
  }

  void reorderNightSteps(int oldIndex, int newIndex) {
    final next = List<RoutineStep>.from(nightSteps.value);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    nightSteps.value = next;
    _persistSteps();
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
