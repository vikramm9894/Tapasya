import 'package:test/test.dart';
import '../../lib/domain/engines/score_engine.dart';

void main() {
  group('ScoreEngine Unit Tests', () {
    test('Perfect day: all 3 non-negotiables, all bonus, and checked in yields 100', () {
      final score = ScoreEngine.calculate(
        nnDone: 3,
        nnTotal: 3,
        bonusDone: 2,
        bonusTotal: 2,
        checkedIn: true,
      );
      expect(score, equals(100));
    });

    test('Zero tasks completed yields 0', () {
      final score = ScoreEngine.calculate(
        nnDone: 0,
        nnTotal: 3,
        bonusDone: 0,
        bonusTotal: 2,
        checkedIn: false,
      );
      expect(score, equals(0));
    });

    test('All non-negotiables done (65%) + check-in (10%) = 75 score (Streak Success)', () {
      final score = ScoreEngine.calculate(
        nnDone: 3,
        nnTotal: 3,
        bonusDone: 0,
        bonusTotal: 2,
        checkedIn: true,
      );
      expect(score, equals(75));
    });

    test('Non-negotiables only without bonus habits scales appropriately', () {
      final score = ScoreEngine.calculate(
        nnDone: 3,
        nnTotal: 3,
        bonusDone: 0,
        bonusTotal: 0,
        checkedIn: true,
      );
      expect(score, equals(100));
    });

    test('Clamps score between 0 and 100', () {
      final score = ScoreEngine.calculate(
        nnDone: 5,
        nnTotal: 3,
        bonusDone: 5,
        bonusTotal: 2,
        checkedIn: true,
      );
      expect(score, lessThanOrEqualTo(100));
    });
  });
}
