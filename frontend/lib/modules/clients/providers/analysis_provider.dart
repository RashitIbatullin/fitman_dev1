//
// This file contains granular providers for calculating and fetching
// individual anthropometric analysis data points.
//
// This approach allows for better separation of concerns and more efficient
// UI updates, as widgets can subscribe only to the data they need.
//

import 'package:equatable/equatable.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';
import 'package:fitman_app/utils/somatotype_calculator.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/providers/auth_provider.dart';

// --- Foundational Data Providers ---

/// Fetches the full User object by its ID.
/// Used to get user-specific data like gender and age for calculations.
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ApiService.getUserById(userId);
});

/// Fetches the fixed, non-periodic anthropometric data for a user (e.g., height).
/// Used as input for various calculations like WHtR.
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
    // A client fetching their own data, or a non-staff user.
    return ApiService.getFixedAnthropometry();
  } else {
    // A staff member fetching data for a specific client.
    return ApiService.getFixedAnthropometryForClient(userId);
  }
});

// --- Calculation/Analysis Providers ---

class MetabolicRateParams extends Equatable {
  final String clientId;
  final String measurementId;

  const MetabolicRateParams({required this.clientId, required this.measurementId});

  @override
  List<Object?> get props => [clientId, measurementId];
}

final metabolicRateProvider =
    FutureProvider.autoDispose.family<MetabolicProfile, MetabolicRateParams>(
        (ref, params) async {
  return ApiService.getMetabolicRate(params.clientId, params.measurementId);
});

/// Calculates the Somatotype string (e.g., "Эктоморф: 65%, ...").
/// This is static for a user as it depends on fixed measurements (wrist, ankle) and gender.
/// It performs the calculation locally using [calculateSomatotype].
final somatotypeStringProvider =
    FutureProvider.family<String, String>((ref, userId) async {
  // Depends on user's gender and their fixed measurements.
  final user = await ref.watch(userProvider(userId).future);
  final fixed = await ref.watch(fixedAnthropometryProvider(userId).future);

  if (fixed == null) {
    return 'Недостаточно данных';
  }
  return calculateSomatotype(
    wristCirc: fixed.wristCirc.toDouble(),
    ankleCirc: fixed.ankleCirc.toDouble(),
    gender: user.gender,
  );
});

/// Calculates the WHtR (Waist-to-Height Ratio) profile for a specific measurement.
/// This is dynamic as it depends on `waistCirc` from the measurement.
/// To ensure data consistency, this provider calls a dedicated backend endpoint
/// which uses the same calculation logic as the recommendation engine.
final whtrProfileProvider =
    FutureProvider.family<WhtrProfile, AnthropometryMeasurement>(
        (ref, measurement) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('Not authenticated');
  }
  if (measurement.id == null) {
    throw Exception('Measurement has no ID');
  }

  final userRoles = user.roles.map((r) => r.name).toSet();
  final isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor');

  if (isStaff && measurement.userId != user.id) {
    // Staff viewing a client's measurement.
    return ApiService.getWhtrForMeasurement(measurement.id!,
        clientId: measurement.userId);
  } else {
    // Client viewing their own measurement.
    return ApiService.getWhtrForMeasurement(measurement.id!);
  }
});

/// Calculates the body shape string (e.g., "Яблоко", "Груша").
/// This is a dynamic parameter that depends on the circumferences of a specific measurement.
/// It performs the calculation locally using [calculateBodyShape].
final bodyShapeProvider =
    Provider.family<String, AnthropometryMeasurement>((ref, measurement) {
  final shape = calculateBodyShape(
    shouldersCirc: measurement.shouldersCirc,
    waistCirc: measurement.waistCirc,
    hipsCirc: measurement.hipsCirc,
  );
  return shape ?? 'Не определен';
});
