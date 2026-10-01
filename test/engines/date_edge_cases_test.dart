import 'package:test/test.dart';
import '../../lib/core/utils/date_utils.dart';
import '../../lib/domain/engines/streak_engine.dart';

void main() {
  group('Date & Streak Edge Case Tests', () {
    test('Date parsing and key generation stays strictly in local timezone', () {
      final date = DateTime(2026, 10, 1, 23, 59, 59); // 11:59:59 PM
      expect(AppDateUtils.toKey(date), equals('2026-10-01'));

      final dateMidnight = DateTime(2026, 10, 2, 0, 1, 0); // 12:01:00 AM next day
      expect(AppDateUtils.toKey(dateMidnight), equals('2026-10-02'));
    });

    test('Month key changes cleanly at midnight on last day of month', () {
      final octEnd = DateTime(2026, 10, 31, 23, 59);
      final novStart = DateTime(2026, 11, 1, 0, 1);

      expect(AppDateUtils.toMonthKey(octEnd), equals('2026-10'));
      expect(AppDateUtils.toMonthKey(novStart), equals('2026-11'));
    });

    test('Day calculation correctly increments across 90 days', () {
      const start = '2026-10-01';
      const end = '2026-12-30';
      final elapsed = AppDateUtils.calculateDayNumber(start, end);
      expect(elapsed, equals(91));
    });

    test('Auto-freeze preserves streak across month boundaries', () {
      final days = [
        DayState.success, // Oct 30
        DayState.success, // Oct 31
        DayState.freeze,  // Nov 1 (auto-freeze applied)
        DayState.success, // Nov 2
      ];
      expect(StreakEngine.currentStreak(days), equals(3));
    });

    test('Recovery mode restores streak after consecutive successes', () {
      final days = [
        DayState.miss,
        DayState.success,
        DayState.success,
      ];
      // 14 prior days - 3 penalty = 11 + 2 recovery days = 13
      final recovered = StreakEngine.computeStreakWithRecovery(
        days: days,
        priorStreakBeforeMiss: 14,
      );
      expect(recovered, equals(13));
    });
  });
}
