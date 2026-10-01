/// Represents a proposed adjustment to a habit's target value.
class AdaptiveGoalSuggestion {
  final String habitId;
  final String habitName;
  final double currentTarget;
  final double proposedTarget;
  final double changePercentage; // e.g. +0.25 or -0.25
  final String rationale;

  const AdaptiveGoalSuggestion({
    required this.habitId,
    required this.habitName,
    required this.currentTarget,
    required this.proposedTarget,
    required this.changePercentage,
    required this.rationale,
  });
}

/// Pure Dart Adaptive Goals Engine.
/// Inspects historical 14-day completion rates and suggests target adjustments.
class AdaptiveGoalEngine {
  const AdaptiveGoalEngine._();

  /// Analyzes a habit's 14-day completion rate ([rate14], range 0.0 to 1.0).
  ///
  /// Thresholds:
  /// - Rate >= 85%: Suggests a +25% increase (e.g. 20 min -> 25 min, or 10 pages -> 12.5 pages)
  /// - Rate < 50%: Suggests a -25% decrease to reduce burnout and maintain consistency
  /// - Otherwise: returns null (habit target is well-calibrated)
  static AdaptiveGoalSuggestion? evaluate({
    required String habitId,
    required String habitName,
    required double currentTarget,
    required double rate14,
  }) {
    if (rate14 >= 0.85) {
      final proposed = (currentTarget * 1.25);
      final rounded = _roundSensibly(proposed);
      return AdaptiveGoalSuggestion(
        habitId: habitId,
        habitName: habitName,
        currentTarget: currentTarget,
        proposedTarget: rounded,
        changePercentage: 0.25,
        rationale: 'Pichhle 14 din mein 85%+ consistency! Target thoda badhane ka samay hai.',
      );
    } else if (rate14 < 0.50) {
      final proposed = (currentTarget * 0.75);
      final rounded = _roundSensibly(proposed);
      return AdaptiveGoalSuggestion(
        habitId: habitId,
        habitName: habitName,
        currentTarget: currentTarget,
        proposedTarget: rounded,
        changePercentage: -0.25,
        rationale: 'Consistency 50% se neeche aayi hai. Target thoda aasan karke momentum wapas pao.',
      );
    }

    return null;
  }

  static double _roundSensibly(double value) {
    if (value >= 10) return value.roundToDouble();
    return double.parse(value.toStringAsFixed(1));
  }
}
