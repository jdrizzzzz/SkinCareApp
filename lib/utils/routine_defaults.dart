import 'package:flutter/material.dart';
import '../models/routine_step.dart';

List<RoutineStep> buildMorningSteps() {
  return [
    RoutineStep(
      id: 'm_cleanser',
      title: 'Cleanser',
      icon: Icons.opacity,
      cardColor: const Color(0xFFF3D7D7),
    ),
    RoutineStep(
      id: 'm_toner',
      title: 'Toner',
      icon: Icons.water_drop_outlined,
      cardColor: const Color(0xFFF4DFDF),
    ),
    RoutineStep(
      id: 'm_serum',
      title: 'Serum',
      icon: Icons.bubble_chart_outlined,
      cardColor: const Color(0xFFF4D2D2),
    ),
    RoutineStep(
      id: 'm_moist',
      title: 'Moisturizer',
      icon: Icons.spa_outlined,
      cardColor: const Color(0xFFEEDCDC),
    ),
    RoutineStep(
      id: 'm_spf',
      title: 'Sunscreen',
      icon: Icons.wb_sunny_outlined,
      cardColor: const Color(0xFFF2DADA),
    ),
  ];
}

List<RoutineStep> buildNightSteps() {
  return [
    RoutineStep(
      id: 'n_cleanser',
      title: 'Cleanser',
      icon: Icons.opacity,
      cardColor: const Color(0xFFE6E0F2),
    ),
    RoutineStep(
      id: 'n_treatment',
      title: 'Treatment',
      icon: Icons.science_outlined,
      cardColor: const Color(0xFFEDE7F8),
    ),
    RoutineStep(
      id: 'n_moist',
      title: 'Moisturizer',
      icon: Icons.spa_outlined,
      cardColor: const Color(0xFFE6E0F2),
    ),
  ];
}
