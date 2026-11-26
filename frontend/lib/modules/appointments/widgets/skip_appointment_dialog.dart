import 'package:flutter/material.dart';

/// Результат диалога пропуска.
class SkipAppointmentResult {
  const SkipAppointmentResult({
    required this.party,
    required this.reason,
    this.note,
  });

  /// 1 — клиент, 2 — сотрудник, 3 — администрация.
  final int party;

  /// Код причины: 1 самочувствие, 2 опоздание, 3 отказ, 4 пересечение,
  /// 5 смена программы, 6 нет специалиста, 7 оборудование, 8 отъезд,
  /// 9 досрочное завершение, 10 иное.
  final int reason;

  final String? note;
}

/// Диалог фиксации пропуска: кто виноват и почему.
class SkipAppointmentDialog extends StatefulWidget {
  const SkipAppointmentDialog({super.key});

  @override
  State<SkipAppointmentDialog> createState() => _SkipAppointmentDialogState();
}

class _SkipAppointmentDialogState extends State<SkipAppointmentDialog> {
  static const Map<int, String> _parties = {
    1: 'Клиент',
    2: 'Сотрудник',
    3: 'Администрация',
  };

  static const Map<int, String> _reasons = {
    1: 'Самочувствие',
    2: 'Опоздание',
    3: 'Отказ клиента',
    4: 'Пересечение записей',
    5: 'Изменение программы',
    6: 'Нет специалиста',
    7: 'Поломка оборудования',
    8: 'Отъезд',
    9: 'Досрочное завершение',
    10: 'Иное',
  };

  int _party = 1;
  int _reason = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Пропуск записи'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'По чьей вине пропуск? От этого зависит, списывается ли сеанс.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _party,
              decoration: const InputDecoration(
                labelText: 'Сторона',
                border: OutlineInputBorder(),
              ),
              items: _parties.entries
                  .map(
                    (entry) => DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _party = value ?? 1),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _reason,
              decoration: const InputDecoration(
                labelText: 'Причина',
                border: OutlineInputBorder(),
              ),
              items: _reasons.entries
                  .map(
                    (entry) => DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value ?? 1),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Комментарий (необязательно)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final note = _noteController.text.trim();
            Navigator.of(context).pop(
              SkipAppointmentResult(
                party: _party,
                reason: _reason,
                note: note.isEmpty ? null : note,
              ),
            );
          },
          child: const Text('Зафиксировать'),
        ),
      ],
    );
  }
}
