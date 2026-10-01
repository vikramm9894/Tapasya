/// Lightweight data models for pure insight calculations.
class CheckinInsightData {
  final double sleepHours;
  final int focus; // 1 - 5
  final int mood;  // 1 - 5
  final int energy; // 1 - 5

  const CheckinInsightData({
    required this.sleepHours,
    required this.focus,
    required this.mood,
    required this.energy,
  });
}

class HabitMissInsightData {
  final String habitName;
  final int dayOfWeek; // 1 (Mon) - 7 (Sun)
  final bool completed;

  const HabitMissInsightData({
    required this.habitName,
    required this.dayOfWeek,
    required this.completed,
  });
}

/// Pure Dart Rule-Based Insight Engine for Tapasya.
/// Calculates actionable behavioral correlations without needing external AI or cloud services.
class InsightEngine {
  const InsightEngine._();

  /// Calculates the correlation between sleeping 7+ hours and focus rating.
  static String? sleepFocusInsight(List<CheckinInsightData> checkins) {
    final good = checkins.where((c) => c.sleepHours >= 7.0).map((c) => c.focus).toList();
    final bad = checkins.where((c) => c.sleepHours < 7.0).map((c) => c.focus).toList();

    if (good.length < 4 || bad.length < 4) return null; // Insufficient data

    final avgGood = good.reduce((a, b) => a + b) / good.length;
    final avgBad = bad.reduce((a, b) => a + b) / bad.length;

    if (avgBad <= 0) return null;

    final diff = avgGood - avgBad;
    if (diff < 0.4) return null; // Insignificant differential

    final pct = ((diff / avgBad) * 100).round();
    return 'Jin dino sleep 7+ ghante thi, focus ~$pct% zyada raha.';
  }

  /// Calculates the correlation between workout/exercise habit and overall mood.
  static String? workoutMoodInsight({
    required List<int> moodOnWorkoutDays,
    required List<int> moodOnRestDays,
  }) {
    if (moodOnWorkoutDays.length < 4 || moodOnRestDays.length < 4) return null;

    final avgWorkout = moodOnWorkoutDays.reduce((a, b) => a + b) / moodOnWorkoutDays.length;
    final avgRest = moodOnRestDays.reduce((a, b) => a + b) / moodOnRestDays.length;

    if (avgRest <= 0) return null;

    final diff = avgWorkout - avgRest;
    if (diff < 0.5) return null;

    final pct = ((diff / avgRest) * 100).round();
    return 'Workout wale din mood average ~$pct% behtar raha.';
  }

  /// Identifies if consistency drops significantly on weekends.
  static String? weekendDropoffInsight({
    required double weekdayCompletionRate,
    required double weekendCompletionRate,
  }) {
    final diff = weekdayCompletionRate - weekendCompletionRate;
    if (diff >= 0.25) {
      final pct = (diff * 100).round();
      return 'Weekends par consistency ~$pct% gir jati hai. Saturday aur Sunday ke liye Morning Sheet subah hi lock karo.';
    }
    return null;
  }
}
