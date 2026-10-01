import 'package:test/test.dart';
import '../../lib/domain/engines/adaptive_goal_engine.dart';

void main() {
  group('AdaptiveGoalEngine Unit Tests', () {
    test('Suggests +25% increase when 14-day completion rate >= 85%', () {
      final suggestion = AdaptiveGoalEngine.evaluate(
        habitId: 'h1',
        habitName: 'Reading',
        currentTarget: 20.0,
        rate14: 0.90,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.changePercentage, equals(0.25));
      expect(suggestion.proposedTarget, equals(25.0));
      expect(suggestion.rationale, contains('85%+ consistency'));
    });

    test('Suggests -25% decrease when 14-day completion rate < 50%', () {
      final suggestion = AdaptiveGoalEngine.evaluate(
        habitId: 'h2',
        habitName: 'Meditation',
        currentTarget: 20.0,
        rate14: 0.40,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.changePercentage, equals(-0.25));
      expect(suggestion.proposedTarget, equals(15.0));
      expect(suggestion.rationale, contains('50% se neeche'));
    });

    test('Returns null when completion rate is balanced (between 50% and 84%)', () {
      final suggestion = AdaptiveGoalEngine.evaluate(
        habitId: 'h3',
        habitName: 'Workout',
        currentTarget: 30.0,
        rate14: 0.70,
      );

      expect(suggestion, isNull);
    });
  });
}
