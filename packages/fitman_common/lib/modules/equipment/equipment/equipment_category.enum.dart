
enum EquipmentCategory {
  cardio(displayName: 'Кардио-оборудование'),
  strength(displayName: 'Силовые тренажёры'),
  freeWeights(displayName: 'Свободные веса'),
  functional(displayName: 'Функциональное оборудование'),
  accessories(displayName: 'Аксессуары'),
  measurement(displayName: 'Измерительное оборудование'),
  other(displayName: 'Прочее');

  final String displayName;

  const EquipmentCategory({required this.displayName});
}
