import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';

extension RepairComplexityUI on RepairComplexity {
  String get displayName {
    switch (this) {
      case RepairComplexity.low:
        return 'Низкая';
      case RepairComplexity.medium:
        return 'Средняя';
      case RepairComplexity.high:
        return 'Высокая';
    }
  }
}
