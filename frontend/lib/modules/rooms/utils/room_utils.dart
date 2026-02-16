import 'package:flutter/material.dart';
import '../models/room/room_type.enum.dart';

extension RoomTypeLocalization on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.groupHall:
        return 'Зал групповых занятий';
      case RoomType.cardioZone:
        return 'Кардио-зона';
      case RoomType.strengthZone:
        return 'Силовая зона';
      case RoomType.mixedZone:
        return 'Смешанная зона';
      case RoomType.studio:
        return 'Студия';
      case RoomType.boxingRing:
        return 'Бокс/единоборства';
      case RoomType.pool:
        return 'Бассейн';
      case RoomType.sauna:
        return 'Сауна';
      case RoomType.lockerRoom:
        return 'Раздевалка';
      case RoomType.reception:
        return 'Ресепшен';
      case RoomType.office:
        return 'Офис';
      case RoomType.other:
        return 'Прочее';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomType.groupHall:
        return Icons.groups;
      case RoomType.cardioZone:
        return Icons.directions_run;
      case RoomType.strengthZone:
        return Icons.fitness_center;
      case RoomType.mixedZone:
        return Icons.blender;
      case RoomType.studio:
        return Icons.self_improvement;
      case RoomType.boxingRing:
        return Icons.sports_mma;
      case RoomType.pool:
        return Icons.pool;
      case RoomType.sauna:
        return Icons.hot_tub;
      case RoomType.lockerRoom:
        return Icons.checkroom;
      case RoomType.reception:
        return Icons.meeting_room;
      case RoomType.office:
        return Icons.work;
      case RoomType.other:
        return Icons.help_outline;
    }
  }
}
