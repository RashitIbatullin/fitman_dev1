String getSomatotypeHelpText(String? profile) {
  if (profile == null || profile == 'Недостаточно данных' || profile == 'Не удалось определить') {
    return 'Нет данных для отображения справки. Введите обхват запястья и лодыжки, чтобы рассчитать соматотип.';
  }

  // Parse the profile string to find the dominant type
  String dominantType = '';
  int maxPercentage = 0;

  final parts = profile.split(', ');
  for (final part in parts) {
    final typeAndPercentage = part.split(': ');
    if (typeAndPercentage.length == 2) {
      final percentage = int.tryParse(typeAndPercentage[1].replaceAll('%', ''));
      if (percentage != null && percentage > maxPercentage) {
        maxPercentage = percentage;
        dominantType = typeAndPercentage[0];
      }
    }
  }

  switch (dominantType) {
    case 'Эктоморф':
      return '''
      **Эктоморф: Характеристики**

      - **Предрасположенность:** Худощавое телосложение, тонкие кости, узкие плечи.
      - **Метаболизм:** Ускоренный, что затрудняет набор мышечной и жировой массы.
      - **Особенность:** Часто может есть много, не набирая вес.
      ''';
    case 'Мезоморф':
      return '''
      **Мезоморф: Характеристики**

      - **Предрасположенность:** Атлетическое телосложение, от природы развитая мускулатура.
      - **Метаболизм:** Сбалансированный, легко набирает мышечную массу и быстро теряет жир.
      - **Особенность:** Считается наиболее предрасположенным к силовым видам спорта.
      ''';
    case 'Эндоморф':
      return '''
      **Эндоморф: Характеристики**

      - **Предрасположенность:** Округлые формы, крупное телосложение, широкие кости.
      - **Метаболизм:** Замедленный, имеется склонность к накоплению жира.
      - **Особенность:** Жир часто откладывается в области живота и бедер.
      ''';
    default:
      return 'Не удалось определить доминирующий тип телосложения для отображения справки.';
  }
}
