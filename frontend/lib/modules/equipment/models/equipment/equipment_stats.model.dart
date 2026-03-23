import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_stats.model.freezed.dart';

@freezed
class EquipmentStats with _$EquipmentStats {
  const factory EquipmentStats({
    required int total,
    required int available,
    required int inUse,
    required int inMaintenance,
    required int outOfOrder,
  }) = _EquipmentStats;
}
