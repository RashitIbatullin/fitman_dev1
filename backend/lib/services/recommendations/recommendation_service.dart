import 'package:fitman_common/fitman_common.dart';

import '../../config/database.dart';
import 'somatotype_helper.dart';

// Helper data classes for clarity
class _ClientData {
  final User user;
  final AnthropometryMeasurement? measurement;
  final AnthropometryFixed? fixedData;
  // final Map<String, dynamic> bioimpedance;

  _ClientData({
    required this.user,
    this.measurement,
    this.fixedData,
    // required this.bioimpedance,
  });
}

class WhtrProfile {
  final double ratio;
  final String gradation;

  WhtrProfile({required this.ratio, required this.gradation});

  Map<String, dynamic> toJson() {
    return {
      'ratio': ratio,
      'gradation': gradation,
    };
  }
}

// New class to hold both start and finish profiles
class WhtrProfiles {
  final WhtrProfile start;
  final WhtrProfile finish;

  WhtrProfiles({required this.start, required this.finish});

  Map<String, dynamic> toJson() {
    return {
      'start': start.toJson(),
      'finish': finish.toJson(),
    };
  }
}

class RecommendationService {
  final db = Database();

  Future<SomatotypeProfile?> getSomatotypeProfileForUser(String userId) async {
    final clientData = await _getClientData(userId);
    if (clientData?.fixedData == null) {
      print('[RecommendationService] Could not get fixed data for somatotype profile.');
      return null;
    }
    final rules = await db.recommendations.getSomatotypeRules();
    final profile = _determineSomatotype(clientData!, rules);
    return profile;
  }

  Future<String> getBodyShapeForUser(String userId) async {
    final clientData = await _getClientData(userId);
    if (clientData == null || clientData.measurement == null) {
      return 'Не определен';
    }
    return _determineBodyShape(clientData.measurement!);
  }

  Future<WhtrProfile?> getWhtrForMeasurement(String measurementId) async {
    final measurement =
        await db.clients.getAnthropometryMeasurementById(measurementId);
    if (measurement == null) return null;

    final clientData =
        await _getClientData(measurement.userId, measurement: measurement);
    if (clientData?.fixedData == null) return null;

    return _determineWhtrProfile(clientData!);
  }

  Future<WhtrProfiles?> getWhtrProfilesForUser(String userId) async {
    final clientData = await _getClientData(userId);
    if (clientData?.fixedData == null || clientData?.measurement == null) {
      print('[RecommendationService] Could not get client data for WHtR profile.');
      return null;
    }
    // TODO: This should calculate for the START and FINISH measurements, not just the latest.
    final profile = _determineWhtrProfile(clientData!);
    return WhtrProfiles(start: profile, finish: profile);
  }

  Future<Map<String, String?>> generateRecommendation(String userId) async {
    print(
        '[RecommendationService] Starting recommendation generation for userId: $userId');

    final clientData = await _getClientData(userId);
    if (clientData?.measurement == null || clientData?.fixedData == null) {
      print(
          '[RecommendationService] ERROR: Failed to get client data or client has no anthropometry.');
      return {
        'client_recommendation':
            'Недостаточно данных для генерации рекомендации.',
        'trainer_recommendation':
            'Клиент не найден или у него отсутствуют антропометрические данные.',
      };
    }

    final rules = await db.recommendations.getSomatotypeRules();
    final baseRecommendations =
        await db.recommendations.getBodyShapeRecommendations();
    final whtrRefinements = await db.recommendations.getWhtrRefinements();

    print(
        '[RecommendationService] Fetched ${baseRecommendations.length} base recommendations and ${whtrRefinements.length} WHtR refinements.');

    final somatotype = _determineSomatotype(clientData!, rules);
    final bodyShape = _determineBodyShape(clientData.measurement!);
    final whtrProfile = _determineWhtrProfile(clientData);

    print('[RecommendationService] Calculated values:');
    print('  - Goal ID: ${clientData.user.clientProfile?.goalTrainingId}');
    print('  - Level ID: ${clientData.user.clientProfile?.levelTrainingId}');
    print('  - Somatotype: $somatotype');
    print('  - Body Shape: $bodyShape');
    print(
        '  - WHtR: ${whtrProfile.ratio.toStringAsFixed(2)} (${whtrProfile.gradation})');

    final recommendation = _buildFinalRecommendation(
      bodyShape: bodyShape,
      whtrGradation: whtrProfile.gradation,
      goalId: clientData.user.clientProfile?.goalTrainingId,
      levelId: clientData.user.clientProfile?.levelTrainingId,
      baseRecommendations: baseRecommendations,
      whtrRefinements: whtrRefinements,
    );

    if (recommendation == null) {
      print(
          '[RecommendationService] ERROR: No matching recommendation found in the database.');
      return {
        'client_recommendation':
            'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.',
        'trainer_recommendation':
            'Не найдено подходящей рекомендации в базе. Проверьте каталоги body_shape_recommendations и whtr_refinements.',
      };
    }

    print('[RecommendationService] Successfully built a combined recommendation.');

    final methodologyExplanation = '''
Рекомендации сформированы на основе комплексного анализа Вашего последнего замера:
*   **Тип фигуры:** $bodyShape
*   **Индекс WHtR:** ${whtrProfile.gradation} (коэф. ${whtrProfile.ratio.toStringAsFixed(2)})

Эти данные, а также ваш соматотип, цели и уровень подготовки, используются для подбора индивидуального плана.
''';

    final clientBaseRec = recommendation['client_recommendation'] ?? '';
    final trainerBaseRec = recommendation['trainer_recommendation'] ?? '';
    final somatotypeHelp = getSomatotypeHelpTextForRecommendation(somatotype);

    final enrichedClientRecommendation =
        methodologyExplanation + clientBaseRec + somatotypeHelp;
    final enrichedTrainerRecommendation =
        methodologyExplanation + trainerBaseRec + somatotypeHelp;

    return {
      'client_recommendation': enrichedClientRecommendation,
      'trainer_recommendation': enrichedTrainerRecommendation,
    };
  }

  Future<_ClientData?> _getClientData(String userId, {AnthropometryMeasurement? measurement}) async {
    final user = await db.users.getUserById(userId);
    if (user == null) return null;

    AnthropometryMeasurement? finalMeasurement = measurement;
    if (finalMeasurement == null) {
      final measurements = await db.clients.getAnthropometryMeasurements(userId);
      finalMeasurement = measurements.isNotEmpty ? measurements.first : null;
    }
    
    final fixedData = await db.clients.getFixedAnthropometry(userId);

    return _ClientData(
      user: user,
      measurement: finalMeasurement,
      fixedData: fixedData,
    );
  }


  SomatotypeProfile _determineSomatotype(
      _ClientData data, List<Map<String, dynamic>> rules) {
    final gender = data.user.gender == 'мужской' ? 'M' : 'Ж';
    final wristCirc = data.fixedData?.wristCirc?.toDouble();
    final ankleCirc = data.fixedData?.ankleCirc?.toDouble();

    if (wristCirc == null) {
      return SomatotypeProfile();
    }

    final scores = <String, double>{};
    final relevantRules = rules
        .where((r) => r['gender'] == gender || r['gender'] == 'ALL')
        .toList();

    for (final rule in relevantRules) {
      final typeName = rule['name'] as String;
      final wristMin = (rule['wrist_min'] as num?)?.toDouble();
      final wristMax = (rule['wrist_max'] as num?)?.toDouble();
      final ankleMin = (rule['ankle_min'] as num?)?.toDouble();
      final ankleMax = (rule['ankle_max'] as num?)?.toDouble();
      final wristScore = _calculateScore(wristCirc, wristMin, wristMax);

      if (ankleCirc != null) {
        final ankleScore = _calculateScore(ankleCirc, ankleMin, ankleMax);
        scores[typeName] = (wristScore + ankleScore) / 2;
      } else {
        scores[typeName] = wristScore;
      }
    }

    final totalScore = scores.values.fold(0.0, (sum, val) => sum + val);
    if (totalScore == 0) return SomatotypeProfile();

    final ecto = (scores['Эктоморф'] ?? 0) / totalScore * 100;
    final meso = (scores['Мезоморф'] ?? 0) / totalScore * 100;
    final endo = (scores['Эндоморф'] ?? 0) / totalScore * 100;

    return SomatotypeProfile(ectomorph: ecto, mesomorph: meso, endomorph: endo);
  }

  double _calculateScore(double value, double? min, double? max) {
    const falloffRange = 2.0;
    const falloffFactor = 100 / falloffRange;

    if (min != null && max != null) {
      if (value >= min && value <= max) return 100;
      if (value > max && value <= max + falloffRange) return 100 - (value - max) * falloffFactor;
      if (value < min && value >= min - falloffRange) return 100 - (min - value) * falloffFactor;
    } else if (min == null && max != null) {
      if (value <= max) return 100;
      if (value > max && value <= max + falloffRange) return 100 - (value - max) * falloffFactor;
    } else if (min != null && max == null) {
      if (value >= min) return 100;
      if (value < min && value >= min - falloffRange) return 100 - (min - value) * falloffFactor;
    }
    return 0;
  }

  String _determineBodyShape(AnthropometryMeasurement measurement) {
    final shoulders = measurement.shouldersCirc?.toDouble();
    final waist = measurement.waistCirc?.toDouble();
    final hips = measurement.hipsCirc?.toDouble();

    if (shoulders == null || waist == null || hips == null || shoulders == 0 || waist == 0 || hips == 0) {
      return 'Не определен';
    }

    final waistToHips = waist / hips;
    final shouldersToHips = (shoulders / hips).abs();

    if (waistToHips >= 0.85 && waist > shoulders && waist > hips) return 'Яблоко';
    if (hips > shoulders * 1.05) return 'Груша';
    if (shouldersToHips >= 0.95 && shouldersToHips <= 1.05) {
      if ((waist / shoulders) < 0.75) return 'Песочные часы';
      return 'Прямоугольник';
    }
    if (shoulders > hips * 1.05) return 'Перевернутый треугольник';

    return 'Не определен';
  }

  WhtrProfile _determineWhtrProfile(_ClientData data) {
    print('--- DETERMINING WHTR PROFILE ---');
    final height = data.fixedData?.height?.toDouble();
    final waist = data.measurement?.waistCirc?.toDouble();
    final age = data.user.age;

    print('Input data: age=$age, height=$height, waist=$waist');

    if (height == null || waist == null || height == 0) {
      print('Result: Incomplete data.');
      return WhtrProfile(ratio: 0, gradation: 'Не определен');
    }

    final ratio = waist / height;
    print('Calculated ratio: $ratio');
    String gradation;

    if (age == null) {
      gradation = 'Не определен';
    } else {
      double upperBound;
      if (age <= 40) {
        upperBound = 0.50;
      } else if (age <= 60) {
        upperBound = 0.53;
      } else {
        upperBound = 0.55;
      }
      print('Determined upperBound for age $age: $upperBound');

      if (ratio < 0.4) {
        gradation = 'Риск истощения';
      } else if (ratio >= 0.4 && ratio <= upperBound) {
        gradation = 'Норма';
      } else if (ratio > upperBound && ratio <= upperBound + 0.1) {
        gradation = 'Избыточный вес';
      } else {
        gradation = 'Ожирение';
      }
    }

    print('Final gradation: $gradation');
    print('--- END WHTR PROFILE ---');
    return WhtrProfile(ratio: ratio, gradation: gradation);
  }

  Map<String, String>? _buildFinalRecommendation({
    required String bodyShape,
    required String whtrGradation,
    required String? goalId,
    required String? levelId,
    required List<Map<String, dynamic>> baseRecommendations,
    required List<Map<String, dynamic>> whtrRefinements,
  }) {
    if (goalId == null || levelId == null) {
      print('[_buildFinalRecommendation] Error: goalId or levelId is null.');
      return null;
    }

    final baseRec = baseRecommendations.firstWhere(
      (rec) =>
          rec['body_type'] == bodyShape &&
          rec['goal_training_id'] == goalId &&
          rec['level_training_id'] == levelId,
      orElse: () => <String, dynamic>{},
    );

    if (baseRec.isEmpty) {
      print('[_buildFinalRecommendation] Could not find a specific base recommendation for body_type: $bodyShape, goal_id: $goalId, level_id: $levelId.');
      return null;
    }

    final refinement = whtrRefinements.firstWhere(
      (ref) =>
          ref['whtr_gradation'] == whtrGradation &&
          ref['goal_training_id'] == goalId,
      orElse: () => <String, dynamic>{},
    );

    final clientText = (baseRec['recommendation_text_client'] ?? '') +
        (refinement['refinement_text_client'] ?? '');

    final trainerText = (baseRec['recommendation_text_trainer'] ?? '') +
        (refinement['refinement_text_trainer'] ?? '');

    return {
      'client_recommendation': clientText,
      'trainer_recommendation': trainerText,
    };
  }
}
