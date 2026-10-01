import 'package:test/test.dart';
import '../../lib/domain/engines/xp_engine.dart';

void main() {
  group('XpEngine Unit Tests', () {
    test('Calculates base XP correctly for difficulty levels', () {
      expect(XpEngine.calculateHabitXp(1), equals(10));
      expect(XpEngine.calculateHabitXp(2), equals(20));
      expect(XpEngine.calculateHabitXp(3), equals(30));
    });

    test('Non-negotiable applies 1.5x multiplier', () {
      expect(XpEngine.calculateHabitXp(1, isNonNeg: true), equals(15));
      expect(XpEngine.calculateHabitXp(2, isNonNeg: true), equals(30));
      expect(XpEngine.calculateHabitXp(3, isNonNeg: true), equals(45));
    });

    test('Bare minimum applies 0.5x multiplier', () {
      expect(XpEngine.calculateHabitXp(2, isBareMin: true), equals(10));
      expect(XpEngine.calculateHabitXp(3, isBareMin: true), equals(15));
    });

    test('Both Non-negotiable and Bare Minimum apply together', () {
      // 20 * 1.5 * 0.5 = 15
      expect(XpEngine.calculateHabitXp(2, isNonNeg: true, isBareMin: true), equals(15));
    });

    test('xpToNext progression curve', () {
      expect(XpEngine.xpToNext(1), equals(500));
      expect(XpEngine.xpToNext(2), equals(650));
      expect(XpEngine.xpToNext(3), equals(800));
    });

    test('levelFor calculates level, remainder into level, and titles', () {
      // Level 1: 0 XP
      final l1 = XpEngine.levelFor(0);
      expect(l1.level, equals(1));
      expect(l1.into, equals(0));
      expect(l1.need, equals(500));
      expect(l1.title, equals('Frost Rookie'));

      // Level 2: 500 XP
      final l2 = XpEngine.levelFor(500);
      expect(l2.level, equals(2));
      expect(l2.into, equals(0));
      expect(l2.need, equals(650));

      // Level 2 with remainder: 600 XP (500 + 100)
      final l2Rem = XpEngine.levelFor(600);
      expect(l2Rem.level, equals(2));
      expect(l2Rem.into, equals(100));

      // Level 20+ Tapasvi
      // L1-19 sum is roughly > 10,000 XP
      final tapasvi = XpEngine.levelFor(40000);
      expect(tapasvi.level, greaterThanOrEqualTo(20));
      expect(tapasvi.title, contains('Tapasvi'));
    });
  });
}
