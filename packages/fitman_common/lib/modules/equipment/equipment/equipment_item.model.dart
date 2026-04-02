import 'package:freezed_annotation/freezed_annotation.dart';
import 'equipment_status.enum.dart';

part 'equipment_item.model.freezed.dart';
part 'equipment_item.model.g.dart';

class EquipmentStatusConverter implements JsonConverter<EquipmentStatus, int> {
  const EquipmentStatusConverter();

  @override
  EquipmentStatus fromJson(int json) => EquipmentStatus.values[json];

  @override
  int toJson(EquipmentStatus object) => object.index;
}



@freezed
class EquipmentItem with _$EquipmentItem {
  const factory EquipmentItem({
    required String id,
    required String typeId,
    required String inventoryNumber,
    String? serialNumber,
    String? model,
    String? manufacturer,
    String? roomId,
    String? placementNote,
    @EquipmentStatusConverter()
    required EquipmentStatus status,
    required int conditionRating,
    String? conditionNotes,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceNotes,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? supplier,
    int? warrantyMonths,
    @Default(0) int usageHours,
    DateTime? lastUsedDate,
    @Default([]) List<String> photoUrls,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  }) = _EquipmentItem;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);
}
