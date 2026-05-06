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
    case 'rower':
      return Icons.rowing;
    case 'plates':
      return Icons.adjust;
    case 'power_rack':
      return Icons.fitness_center; // General fitness equipment
    case 'smith_machine':
      return Icons.fitness_center; // General fitness equipment
    case 'trx':
      return Icons.monitor_weight; // Strength icon
    case 'med_ball':
      return Icons.sports_baseball; // Ball-like icon
    case 'plyo_box':
      return Icons.square; // Simple geometric shape
    case 'jump_rope':
      return Icons.linear_scale; // Represents a rope
    case 'mat':
      return Icons.crop_square; // Represents a mat
    case 'foam_roller':
      return Icons.line_weight; // Represents a roller
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
    'rower',
    'plates',
    'power_rack',
    'smith_machine',
    'trx',
    'med_ball',
    'plyo_box',
    'jump_rope',
    'mat',
    'foam_roller',
    ];
    }

    // Helper function to get schematic icon display names
    String getSchematicIconDisplayName(String iconName) {
    switch (iconName) {
    case 'dumbbell':
      return 'Гантель';
    case 'treadmill':
      return 'Беговая дорожка';
    case 'bike':
      return 'Велотренажер';
    case 'elliptical':
      return 'Эллиптический тренажер';
    case 'barbell':
      return 'Штанга';
    case 'bench':
      return 'Скамья';
    case 'leg_press':
      return 'Жим ногами';
    case 'fitball':
      return 'Фитбол';
    case 'yoga_mat':
      return 'Коврик для йоги';
    case 'scales':
      return 'Весы';
    case 'crossover':
      return 'Кроссовер';
    case 'kettlebell':
      return 'Гиря';
    case 'pull_block':
      return 'Тяга блока';
    case 'stepper':
      return 'Степпер';
    case 'hammer_chest':
      return 'Хаммер для груди';
    case 'aerobic_step':
      return 'Степ-платформа';
    case 'punching_bag':
      return 'Боксерская груша';
    case 'rower':
      return 'Гребной тренажер';
    case 'plates':
      return 'Блины';
    case 'power_rack':
      return 'Силовая рама';
    case 'smith_machine':
      return 'Машина Смита';
    case 'trx':
      return 'Петли TRX';
    case 'med_ball':
      return 'Медицинский мяч';
    case 'plyo_box':
      return 'Плиометрический бокс';
    case 'jump_rope':
      return 'Скакалка';
    case 'mat':
      return 'Коврик';
    case 'foam_roller':
      return 'Массажный ролик';
    default:
      return iconName; // Fallback to the original name
    }
    }