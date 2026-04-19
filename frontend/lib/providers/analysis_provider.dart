import 'package:fitman_common/fitman_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// NOTE: This class is a placeholder for a future model in `fitman_common`.
// It represents the analysis data for a single point in time.
class SingleAnalysisData {
  SingleAnalysisData({
    required this.bodyShape,
    required this.somatotypeProfile,
    required this.whtrProfile,
  });

  final String bodyShape;
  final String somatotypeProfile;
  final WhtrProfile whtrProfile;
}

// NOTE: This provider is a MOCK for UI development.
// It will be replaced with a real API call to an endpoint like:
// GET /api/admin/clients/:id/analysis?measurement_id=<uuid>
final singleAnalysisProvider =
    FutureProvider.family<SingleAnalysisData, String>((ref, measurementId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  // We use a pseudo-random way to return different data for demonstration.
  if (measurementId.hashCode.isEven) {
    return SingleAnalysisData(
      bodyShape: 'Перевернутый треугольник',
      somatotypeProfile: 'Эктоморф: 1-4-5',
      whtrProfile: WhtrProfile(ratio: 0.45, gradation: 'Норма'),
    );
  }
  return SingleAnalysisData(
    bodyShape: 'Прямоугольник',
    somatotypeProfile: 'Мезоморф: 3-5-2',
    whtrProfile: WhtrProfile(ratio: 0.51, gradation: 'Избыточный вес'),
  );
});
