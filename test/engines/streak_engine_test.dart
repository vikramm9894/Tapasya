import 'package:test/test.dart';
import '../../lib/domain/engines/streak_engine.dart';

void main() {
  group('StreakEngine Unit Tests', () {
    test('Calculates simple continuous streak', () {
      final days = [
        DayState.success,
        DayState.success,
        DayState.success,
        DayState.success,
        DayState.success,
      ];
      expect(StreakEngine.currentStreak(days), equals(5));
    });

    test('Planned rest days preserve streak without incrementing', () {
      final days = [
        DayState.success, // Day 1
        DayState.success, // Day 2
        DayState.rest,    // Day 3 (Sunday rest)
        DayState.success, // Day 4
        DayState.success, // Day 5
      ];
      // Total successes = 4, streak = 4 (rest is skipped)
      expect(StreakEngine.currentStreak(days), equals(4));
    });

    test('Freeze days preserve streak without incrementing', () {
      final days = [
        DayState.success,
        DayState.success,
        DayState.freeze, // Auto-frozen day
        DayState.success,
      ];
      expect(StreakEngine.currentStreak(days), equals(3));
    });

    test('Miss breaks the streak', () {
      final days = [
        DayState.success,
        DayState.success,
        DayState.success,
        DayState.miss,    // Streak broken here
        DayState.success, // Restart
        DayState.success,
      ];
      // Only the recent consecutive streak counts
      expect(StreakEngine.currentStreak(days), equals(2));
    });

    test('Empty days list returns 0', () {
      expect(StreakEngine.currentStreak([]), equals(0));
    });

    test('classify sets DayState.rest when mode is rest', () {
      final state = StreakEngine.classify(mode: 'rest', score: 0, allNnDone: false);
      expect(state, equals(DayState.rest));
    });

    test('classify sets DayState.freeze when mode is freeze', () {
      final state = StreakEngine.classify(mode: 'freeze', score: 0, allNnDone: false);
      expect(state, equals(DayState.freeze));
    });

    test('classify sets DayState.success for bare_min even with 0 score', () {
      final state = StreakEngine.classify(mode: 'bare_min', score: 40, allNnDone: false);
      expect(state, equals(DayState.success));
    });

    test('classify sets DayState.success for score >= 70', () {
      final state = StreakEngine.classify(mode: 'normal', score: 70, allNnDone: false);
      expect(state, equals(DayState.success));
    });

    test('classify sets DayState.success when all non-negotiables done', () {
      final state = StreakEngine.classify(mode: 'normal', score: 65, allNnDone: true);
      expect(state, equals(DayState.success));
    });

    test('classify sets DayState.miss when score < 70 and not all NN done', () {
      final state = StreakEngine.classify(mode: 'normal', score: 55, allNnDone: false);
      expect(state, equals(DayState.miss));
    });

    test('Streak recovery restores old streak minus 3 days penalty after 2 successes', () {
      // User had 10-day streak, suffered a miss, then completed 2 successful days
      final days = [
        DayState.miss,
        DayState.success,
        DayState.success,
      ];
      // prior = 10, penalty = 3 -> 7 restored + 2 new days = 9
      final recovered = StreakEngine.computeStreakWithRecovery(
        days: days,
        priorStreakBeforeMiss: 10,
      );
      expect(recovered, equals(9));
    });
  });
}
