import 'package:fitman_common/fitman_common.dart';

/// Границы одного периода квоты.
class QuotaPeriodDraft {
  const QuotaPeriodDraft({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Расчёт календарных периодов квоты («8 в месяц»).
///
/// Первый период начинается с момента активации, следующие — по календарю:
/// день с полуночи, неделя с понедельника, месяц с того же числа
/// (31-е → последний день месяца). Неиспользованная квота не переносится,
/// поэтому периоды только нарезают срок и не зависят от расхода.
class QuotaPeriodCalculator {
  const QuotaPeriodCalculator();

  /// Не больше 500 периодов: защита от услуги «на 100 лет» с дневной квотой.
  static const int maxPeriods = 500;

  List<QuotaPeriodDraft> build({
    required DateTime activation,
    required DateTime? expiry,
    required int? quotaPeriod,
    required int quotaLimit,
  }) {
    if (quotaLimit <= 0) {
      return const [];
    }

    final periods = <QuotaPeriodDraft>[];
    var index = 0;
    while (index < maxPeriods) {
      final start = index == 0
          ? activation
          : _boundary(activation, index, quotaPeriod);
      if (expiry != null && !start.isBefore(expiry)) {
        break;
      }
      periods.add(
        QuotaPeriodDraft(
          start: start,
          end: _boundary(activation, index + 1, quotaPeriod),
        ),
      );
      index++;
      // Без срока действия открываем только текущий период.
      if (expiry == null) {
        break;
      }
    }
    return periods;
  }

  /// Начало периода с номером [index]; индекс 0 — момент активации.
  DateTime _boundary(DateTime activation, int index, int? quotaPeriod) {
    switch (quotaPeriod) {
      case ServiceQuotaPeriod.day:
        return _date(
          activation,
          activation.year,
          activation.month,
          activation.day + index,
        );
      case ServiceQuotaPeriod.week:
        final daysToMonday = (8 - activation.weekday) % 7;
        final firstMonday =
            daysToMonday == 0 ? 7 : daysToMonday;
        return _date(
          activation,
          activation.year,
          activation.month,
          activation.day + firstMonday + (index - 1) * 7,
        );
      case ServiceQuotaPeriod.month:
      default:
        return _addMonths(activation, index);
    }
  }

  /// Добавляет месяцы к [anchor], сохраняя исходное число месяца.
  ///
  /// 31 января + 1 месяц = 28/29 февраля, + 2 месяца = 31 марта:
  /// «день якоря» не дрейфует из-за короткого месяца.
  DateTime _addMonths(DateTime anchor, int months) {
    final total = anchor.month - 1 + months;
    final year = anchor.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = _date(anchor, year, month + 1, 0).day;
    final day = anchor.day > lastDay ? lastDay : anchor.day;
    return _date(
      anchor,
      year,
      month,
      day,
      anchor.hour,
      anchor.minute,
      anchor.second,
      anchor.millisecond,
      anchor.microsecond,
    );
  }

  /// Создаёт дату в той же зоне (UTC или локальной), что и [sample].
  DateTime _date(
    DateTime sample,
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    if (sample.isUtc) {
      return DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
    }
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}
