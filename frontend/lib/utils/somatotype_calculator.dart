
// Данные из ТЗ, скорректированные для более гибкого расчета
const List<Map<String, dynamic>> typesBodyBuildData = [
  {'name': 'Эктоморф', 'gender': 'M', 'wrist_min': null, 'wrist_max': 17.5, 'ankle_min': null, 'ankle_max': 21.5},
  {'name': 'Мезоморф', 'gender': 'M', 'wrist_min': 17.5, 'wrist_max': 19.5, 'ankle_min': 21.5, 'ankle_max': 25.5},
  {'name': 'Эндоморф', 'gender': 'M', 'wrist_min': 19.5, 'wrist_max': null, 'ankle_min': 25.5, 'ankle_max': null},
  {'name': 'Эктоморф', 'gender': 'Ж', 'wrist_min': null, 'wrist_max': 15.5, 'ankle_min': null, 'ankle_max': 21.5},
  {'name': 'Мезоморф', 'gender': 'Ж', 'wrist_min': 15.5, 'wrist_max': 17.5, 'ankle_min': 21.5, 'ankle_max': 25.5},
  {'name': 'Эндоморф', 'gender': 'Ж', 'wrist_min': 17.5, 'wrist_max': null, 'ankle_min': 25.5, 'ankle_max': null},
];

String calculateSomatotype({
  required double? wristCirc,
  required double? ankleCirc,
  required String? gender,
}) {
  if (wristCirc == null || gender == null) {
    return 'Недостаточно данных';
  }

  final genderChar = gender.toLowerCase().startsWith('м') ? 'M' : 'Ж';

  final scores = <String, double>{
    'Эктоморф': 0,
    'Мезоморф': 0,
    'Эндоморф': 0,
  };

  for (final typeData in typesBodyBuildData) {
    if (typeData['gender'] == genderChar) {
      final typeName = typeData['name'] as String;
      double wristScore = 0;
      double ankleScore = 0;

      final wristMin = typeData['wrist_min'] as double?;
      final wristMax = typeData['wrist_max'] as double?;
      final ankleMin = typeData['ankle_min'] as double?;
      final ankleMax = typeData['ankle_max'] as double?;

      wristScore = _calculateScore(wristCirc, wristMin, wristMax);
      
      if (ankleCirc != null) {
        ankleScore = _calculateScore(ankleCirc, ankleMin, ankleMax);
        scores[typeName] = (wristScore + ankleScore) / 2;
      } else {
        scores[typeName] = wristScore;
      }
    }
  }

  final totalScore = scores.values.reduce((a, b) => a + b);
  if (totalScore == 0) {
    return 'Не удалось определить';
  }

  // Нормализация процентов
  final normalizedScores = <String, int>{};
  int totalPercentage = 0;
  scores.forEach((key, value) {
    final percentage = (value / totalScore * 100).round();
    normalizedScores[key] = percentage;
    totalPercentage += percentage;
  });

  // Корректировка, чтобы сумма была 100%
  if (totalPercentage != 100 && normalizedScores.isNotEmpty) {
      final difference = 100 - totalPercentage;
      final maxScoreKey = normalizedScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      normalizedScores[maxScoreKey] = normalizedScores[maxScoreKey]! + difference;
  }

  final profile = normalizedScores.entries.map((entry) {
    return '${entry.key}: ${entry.value}%';
  }).join(', ');

  return profile;
}

double _calculateScore(double value, double? min, double? max) {
  const falloffRange = 2.0;
  const falloffFactor = 100 / falloffRange;

  if (min != null && max != null) { // Мезоморф
    if (value >= min && value <= max) {
      return 100;
    } else if (value > max && value <= max + falloffRange) {
      return 100 - (value - max) * falloffFactor;
    } else if (value < min && value >= min - falloffRange) {
      return 100 - (min - value) * falloffFactor;
    }
  } else if (min == null && max != null) { // Эктоморф
    if (value <= max) {
      return 100;
    } else if (value > max && value <= max + falloffRange) {
      return 100 - (value - max) * falloffFactor;
    }
  } else if (min != null && max == null) { // Эндоморф
    if (value >= min) {
      return 100;
    } else if (value < min && value >= min - falloffRange) {
      return 100 - (min - value) * falloffFactor;
    }
  }
  return 0;
}