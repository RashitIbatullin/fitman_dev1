String? calculateBodyShape({
  //обхват плеч
  required int? shouldersCirc,
  //обхват талии
  required int? waistCirc,
  //обхват бедер
  required int? hipsCirc,
}) {
  if (shouldersCirc == null || waistCirc == null || hipsCirc == null || shouldersCirc == 0 || hipsCirc == 0) {
    return null;
  }

  if (waistCirc / hipsCirc >= 0.85 && waistCirc > shouldersCirc && waistCirc > hipsCirc) {
    return 'Яблоко';
  }
  if (hipsCirc > shouldersCirc * 1.05) {
    return 'Груша';
  }
  if ((shouldersCirc - hipsCirc).abs() < 0.05 * shouldersCirc && (waistCirc / shouldersCirc) < 0.75) {
    return 'Песочные часы';
  }
  if ((shouldersCirc - hipsCirc).abs() < 0.05 * shouldersCirc && (waistCirc / shouldersCirc) >= 0.75) {
    return 'Прямоугольник';
  }
  if (shouldersCirc > hipsCirc * 1.05) {
    return 'Перевернутый треугольник';
  }

  return 'Не определен';
}
