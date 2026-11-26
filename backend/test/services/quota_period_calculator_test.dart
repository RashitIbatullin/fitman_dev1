import 'package:fitman_backend/modules/services/services/quota_period_calculator.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:test/test.dart';

void main() {
  const calculator = QuotaPeriodCalculator();

  group('QuotaPeriodCalculator', () {
    test('дневная квота режется по полуночи и не выходит за срок', () {
      final activation = DateTime.utc(2026, 1, 15, 14, 30);
      final periods = calculator.build(
        activation: activation,
        expiry: activation.add(const Duration(days: 3)),
        quotaPeriod: ServiceQuotaPeriod.day,
        quotaLimit: 1,
      );

      expect(periods, hasLength(4));
      expect(periods.first.start, activation);
      expect(periods.first.end, DateTime.utc(2026, 1, 16));
      expect(periods[1].start, DateTime.utc(2026, 1, 16));
      expect(periods.last.start, DateTime.utc(2026, 1, 18));
      expect(periods.last.end, DateTime.utc(2026, 1, 19));
    });

    test('недельная квота начинается с понедельника', () {
      final activation = DateTime.utc(2026, 1, 14, 10); // среда
      final periods = calculator.build(
        activation: activation,
        expiry: activation.add(const Duration(days: 21)),
        quotaPeriod: ServiceQuotaPeriod.week,
        quotaLimit: 8,
      );

      expect(periods, hasLength(4));
      expect(periods[1].start, DateTime.utc(2026, 1, 19)); // понедельник
      expect(periods[2].start, DateTime.utc(2026, 1, 26));
      expect(periods.last.start, DateTime.utc(2026, 2, 2));
    });

    test('месячная квота не дрейфует с 31-го числа', () {
      final activation = DateTime.utc(2026, 1, 31, 9);
      final periods = calculator.build(
        activation: activation,
        expiry: DateTime.utc(2026, 4, 30, 9),
        quotaPeriod: ServiceQuotaPeriod.month,
        quotaLimit: 8,
      );

      expect(periods, hasLength(3));
      expect(periods[0].end, DateTime.utc(2026, 2, 28, 9));
      expect(periods[1].start, DateTime.utc(2026, 2, 28, 9));
      expect(periods[1].end, DateTime.utc(2026, 3, 31, 9));
      expect(periods[2].start, DateTime.utc(2026, 3, 31, 9));
      expect(periods[2].end, DateTime.utc(2026, 4, 30, 9));
    });

    test('без срока действия открывается только один период', () {
      final periods = calculator.build(
        activation: DateTime.utc(2026, 1, 15, 14, 30),
        expiry: null,
        quotaPeriod: ServiceQuotaPeriod.month,
        quotaLimit: 8,
      );

      expect(periods, hasLength(1));
    });

    test('нулевая квота не создаёт периодов', () {
      final periods = calculator.build(
        activation: DateTime.utc(2026, 1, 15),
        expiry: DateTime.utc(2026, 2, 15),
        quotaPeriod: ServiceQuotaPeriod.month,
        quotaLimit: 0,
      );

      expect(periods, isEmpty);
    });
  });
}
