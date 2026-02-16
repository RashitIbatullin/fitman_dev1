// ignore_for_file: constant_identifier_names

enum RoomType {
  groupHall(0),      // Зал групповых занятий
  cardioZone(1),     // Кардио-зона
  strengthZone(2),   // Силовая зона
  mixedZone(3),      // Смешанная зона
  studio(4),         // Студия (йога, пилатес)
  boxingRing(5),     // Бокс/единоборства
  pool(6),           // Бассейн
  sauna(7),          // Сауна
  lockerRoom(8),     // Раздевалка
  reception(9),      // Ресепшен
  office(10),        // Офис
  other(11);         // Прочее

  final int value;
  const RoomType(this.value);
}