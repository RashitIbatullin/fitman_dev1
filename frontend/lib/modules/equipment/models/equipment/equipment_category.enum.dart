import 'package:flutter/material.dart';

enum EquipmentCategory {
  cardio(displayName: 'Кардио-оборудование', icon: Icons.favorite_border),
  strength(displayName: 'Силовые тренажёры', icon: Icons.fitness_center),
  freeWeights(displayName: 'Свободные веса', icon: Icons.accessibility_new),
  functional(displayName: 'Функциональное оборудование', icon: Icons.self_improvement),
  accessories(displayName: 'Аксессуары', icon: Icons.extension),
  measurement(displayName: 'Измерительное оборудование', icon: Icons.straighten),
  other(displayName: 'Прочее', icon: Icons.category);

  final String displayName;
  final IconData icon;

  const EquipmentCategory({required this.displayName, required this.icon});
}
