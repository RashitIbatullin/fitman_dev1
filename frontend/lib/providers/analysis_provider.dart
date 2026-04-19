import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';
import 'package:fitman_app/utils/somatotype_calculator.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Individual Providers for specific calculations ---

// Provider to get user details
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ApiService.getUserById(userId);
});

// Provider to get fixed anthropometry data
final fixedAnthropometryProvider =
    FutureProvider.family<AnthropometryFixed?, String>((ref, userId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) throw Exception('Not authenticated');

  final userRoles = user.roles.map((r) => r.name).toSet();
  final isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor');

  if (user.id == userId || !isStaff) {
    return ApiService.getFixedAnthropometry();
  } else {
    return ApiService.getFixedAnthropometryForClient(userId);
  }
});

/// Calculates the Somatotype string.
/// This is static for a user as it depends on fixed measurements.
final somatotypeStringProvider =
    FutureProvider.family<String, String>((ref, userId) async {
  final user = await ref.watch(userProvider(userId).future);
  final fixed = await ref.watch(fixedAnthropometryProvider(userId).future);

  return calculateSomatotype(
    wristCirc: fixed?.wristCirc?.toDouble(),
    ankleCirc: fixed?.ankleCirc?.toDouble(),
    gender: user.gender,
  );
});

/// Calculates the WHtR profile for a specific measurement.
/// This is dynamic as it depends on `waistCirc` from the measurement.
final whtrProfileProvider =
    FutureProvider.family<WhtrProfile, AnthropometryMeasurement>((ref, measurement) async {
  final fixed = await ref.watch(fixedAnthropometryProvider(measurement.userId).future);
  final height = fixed?.height;
  final waist = measurement.waistCirc;

  if (height == null || height == 0 || waist == null) {
    return WhtrProfile(ratio: 0, gradation: 'Нет данных');
  }

  final ratio = waist / height;
  String gradation;
  // Note: This logic for gradation might need to be verified against backend logic.
  if (ratio < 0.4) {
    gradation = 'Экстремальная худоба';
  } else if (ratio < 0.5) {
    gradation = 'Норма';
  } else if (ratio < 0.6) {
    gradation = 'Избыточный вес';
  } else {
    gradation = 'Ожирение';
  }

  return WhtrProfile(ratio: ratio, gradation: gradation);
});


/// Returns a body shape string by performing a local calculation.
final bodyShapeProvider =
    Provider.family<String, AnthropometryMeasurement>((ref, measurement) {
  final shape = calculateBodyShape(
    shouldersCirc: measurement.shouldersCirc,
    waistCirc: measurement.waistCirc,
    hipsCirc: measurement.hipsCirc,
  );
  return shape ?? 'Не определен';
});
