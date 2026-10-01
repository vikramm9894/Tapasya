/// Day state classification for the Smart Streak Engine.
enum DayState {
  success,
  rest,
  freeze,
  miss,
}

/// Pure Dart Smart Streak Engine for Tapasya.
/// Computes streaks from chronological daily state logs instead of a mutable counter.
class StreakEngine {
  const StreakEngine._();

  /// Computes current streak from chronologically ordered [days] (oldest to most recent).
  ///
  /// Rules:
  /// - [DayState.success]: Increments streak count.
  /// - [DayState.rest]: Preserves streak without incrementing or breaking.
  /// - [DayState.freeze]: Preserves streak without incrementing or breaking.
  /// - [DayState.miss]: Breaks streak.
  static int currentStreak(List<DayState> days) {
    var streak = 0;
    for (final day in days.reversed) {
      switch (day) {
        case DayState.success:
          streak++;
          break;
        case DayState.rest:
        case DayState.freeze:
          // Skip day without breaking or incrementing streak
          continue;
        case DayState.miss:
          return streak;
      }
    }
    return streak;
  }

  /// Classifies a day's performance into a [DayState].
  ///
  /// Criteria for Success:
  /// 1. Explicit `bare_min` mode, OR
  /// 2. Daily score >= 70, OR
  /// 3. All non-negotiables completed.
  static DayState classify({
    required String? mode,
    required int score,
    required bool allNnDone,
  }) {
    if (mode == 'rest') return DayState.rest;
    if (mode == 'freeze') return DayState.freeze;
    if (mode == 'bare_min' || score >= 70 || allNnDone) {
      return DayState.success;
    }
    return DayState.miss;
  }

  /// Evaluates whether streak recovery applies.
  ///
  /// If a user suffers a single miss with zero freezes remaining,
  /// but immediately follows with 2 consecutive [DayState.success] days,
  /// their previous streak is restored minus a 3-day penalty (minimum 2 days).
  static int computeStreakWithRecovery({
    required List<DayState> days,
    required int priorStreakBeforeMiss,
  }) {
    if (days.length < 2) return currentStreak(days);

    final lastTwo = days.sublist(days.length - 2);
    final recoveryAchieved = lastTwo.every((d) => d == DayState.success);

    if (recoveryAchieved && priorStreakBeforeMiss > 3) {
      final restored = priorStreakBeforeMiss - 3;
      return restored + 2; // restored streak + the 2 recovery days
    }

    return currentStreak(days);
  }
}
