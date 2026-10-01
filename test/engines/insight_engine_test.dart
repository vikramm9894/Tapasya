import 'package:test/test.dart';
import '../../lib/domain/engines/insight_engine.dart';

void main() {
  group('InsightEngine Unit Tests', () {
    test('Calculates sleep-focus insight when enough data and significant differential exists', () {
      final checkins = [
        // 4 days with >= 7 hours sleep, average focus = 4.5
        const CheckinInsightData(sleepHours: 8.0, focus: 5, mood: 4, energy: 4),
        const CheckinInsightData(sleepHours: 7.5, focus: 4, mood: 4, energy: 4),
        const CheckinInsightData(sleepHours: 7.0, focus: 4, mood: 4, energy: 3),
        const CheckinInsightData(sleepHours: 8.0, focus: 5, mood: 5, energy: 5),

        // 4 days with < 7 hours sleep, average focus = 2.5
        const CheckinInsightData(sleepHours: 5.5, focus: 2, mood: 2, energy: 2),
        const CheckinInsightData(sleepHours: 6.0, focus: 3, mood: 3, energy: 2),
        const CheckinInsightData(sleepHours: 5.0, focus: 2, mood: 2, energy: 2),
        const CheckinInsightData(sleepHours: 6.0, focus: 3, mood: 2, energy: 3),
      ];

      final insight = InsightEngine.sleepFocusInsight(checkins);
      expect(insight, isNotNull);
      expect(insight, contains('sleep 7+ ghante thi'));
      expect(insight, contains('focus'));
    });

    test('Returns null when data is insufficient (< 4 days in either group)', () {
      final checkins = [
        const CheckinInsightData(sleepHours: 8.0, focus: 5, mood: 4, energy: 4),
        const CheckinInsightData(sleepHours: 5.5, focus: 2, mood: 2, energy: 2),
      ];

      final insight = InsightEngine.sleepFocusInsight(checkins);
      expect(insight, isNull);
    });

    test('Identifies weekend drop-off when difference >= 25%', () {
      final insight = InsightEngine.weekendDropoffInsight(
        weekdayCompletionRate: 0.85,
        weekendCompletionRate: 0.50,
      );

      expect(insight, isNotNull);
      expect(insight, contains('Weekends par consistency'));
    });
  });
}
