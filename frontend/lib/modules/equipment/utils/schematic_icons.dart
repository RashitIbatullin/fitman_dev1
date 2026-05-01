import 'package:flutter/material.dart';

// Helper function for schematic icons
IconData getSchematicIcon(String? iconName) {
  if (iconName == null || iconName.isEmpty) {
    return Icons.category; // Default icon if not found
  }
  switch (iconName) {
    case 'dumbbell':
      return Icons.fitness_center;
    case 'treadmill':
      return Icons.directions_run;
    case 'bike':
      return Icons.pedal_bike;
    case 'elliptical':
      return Icons.directions_walk;
    case 'barbell':
      return Icons.sports_gymnastics;
    case 'bench':
      return Icons.chair; // Placeholder
    case 'leg_press':
      return Icons.view_sidebar; // Placeholder
    case 'fitball':
      return Icons.sports_basketball; // Placeholder
    case 'yoga_mat':
      return Icons.spa; // Using spa for yoga mat
    case 'scales':
      return Icons.scale;
    case 'crossover':
      return Icons.cable; // Placeholder icon
    case 'kettlebell':
      return Icons.fitness_center; // Placeholder icon
    case 'pull_block':
      return Icons.sports_gymnastics; // Placeholder icon
    case 'stepper':
      return Icons.directions_walk; // Placeholder icon
    case 'hammer_chest':
      return Icons.fitness_center; // Placeholder icon
    case 'aerobic_step':
      return Icons.directions_walk; // Placeholder icon
    case 'punching_bag':
      return Icons.sports_mma; // Placeholder icon
    default:
      return Icons.category; // Default icon if not found
  }
}

// Helper function to get schematic icon names
List<String> getSchematicIconNames() {
  return [
    'dumbbell',
    'treadmill',
    'bike',
    'elliptical',
    'barbell',
    'bench',
    'leg_press',
    'fitball',
    'yoga_mat',
    'scales',
    'crossover',
    'kettlebell',
    'pull_block',
    'stepper',
    'hammer_chest',
    'aerobic_step',
    'punching_bag',
  ];
}