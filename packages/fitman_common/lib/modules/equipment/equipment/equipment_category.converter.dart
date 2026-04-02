import 'package:json_annotation/json_annotation.dart';
import 'equipment_category.enum.dart';

class EquipmentCategoryConverter implements JsonConverter<EquipmentCategory, int> {
  const EquipmentCategoryConverter();

  @override
  EquipmentCategory fromJson(int json) {
    switch (json) {
      case 0:
        return EquipmentCategory.cardio;
      case 1:
        return EquipmentCategory.strength;
      case 2:
        return EquipmentCategory.freeWeights;
      case 3:
        return EquipmentCategory.functional;
      case 4:
        return EquipmentCategory.accessories;
      case 5:
        return EquipmentCategory.measurement;
      case 6:
        return EquipmentCategory.other;
      default:
        return EquipmentCategory.other;
    }
  }

  @override
  int toJson(EquipmentCategory object) {
    return object.index;
  }
}
