import 'package:fitman_common/modules/equipment/equipment/equipment_category.enum.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_status.enum.dart';
import 'package:fitman_common/modules/equipment/equipment_maintenance_history.model.dart';
import 'package:flutter/material.dart';

extension EquipmentCategoryUI on EquipmentCategory {
  IconData get icon {
    switch (this) {
      case EquipmentCategory.cardio:
        return Icons.favorite_border;
      case EquipmentCategory.strength:
        return Icons.fitness_center;
      case EquipmentCategory.freeWeights:
        return Icons.accessibility_new;
      case EquipmentCategory.functional:
        return Icons.self_improvement;
      case EquipmentCategory.accessories:
        return Icons.extension;
      case EquipmentCategory.measurement:
        return Icons.straighten;
      case EquipmentCategory.other:
        return Icons.category;
    }
  }
}

extension EquipmentStatusUI on EquipmentStatus {
  Color get color {
    switch (this) {
      case EquipmentStatus.available:
        return Colors.green;
      case EquipmentStatus.inUse:
        return Colors.blue;
      case EquipmentStatus.reserved:
        return Colors.orange;
      case EquipmentStatus.maintenance:
        return Colors.purple;
      case EquipmentStatus.outOfOrder:
        return Colors.red;
      case EquipmentStatus.storage:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case EquipmentStatus.available:
        return Icons.check_circle_outline;
      case EquipmentStatus.inUse:
        return Icons.sync;
      case EquipmentStatus.reserved:
        return Icons.bookmark_border;
      case EquipmentStatus.maintenance:
        return Icons.build;
      case EquipmentStatus.outOfOrder:
        return Icons.error_outline;
      case EquipmentStatus.storage:
        return Icons.inventory_2_outlined;
    }
  }
}

extension MaintenanceStatusUI on MaintenanceStatus {
  Color get color {
    switch (this) {
      case MaintenanceStatus.reported:
        return Colors.orange;
      case MaintenanceStatus.diagnosing:
        return Colors.blue;
      case MaintenanceStatus.inProgress:
        return Colors.purple;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.cancelled:
        return Colors.grey;
    }
  }
}
