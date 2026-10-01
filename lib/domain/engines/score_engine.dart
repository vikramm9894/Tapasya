/// Pure Dart Daily Score Engine for Tapasya.
/// Calculates a score from 0 to 100 based on completed non-negotiables,
/// bonus habits, and the evening check-in.
class ScoreEngine {
  const ScoreEngine._();

  /// Calculates the daily score (0 - 100).
  ///
  /// Weighting:
  /// - Non-negotiable habits: 65%
  /// - Bonus habits: 25%
  /// - Evening check-in: 10%
  static int calculate({
    required int nnDone,
    required int nnTotal,
    required int bonusDone,
    required int bonusTotal,
    required bool checkedIn,
  }) {
    final double nnRatio = nnTotal <= 0 ? (nnDone > 0 ? 1.0 : 0.0) : (nnDone / nnTotal).clamp(0.0, 1.0);
    final double bonusRatio = bonusTotal <= 0 ? 0.0 : (bonusDone / bonusTotal).clamp(0.0, 1.0);
    
    // If no bonus habits exist, scale non-negotiables to 90%
    final double raw = bonusTotal <= 0
        ? (0.90 * nnRatio + (checkedIn ? 0.10 : 0.0))
        : (0.65 * nnRatio + 0.25 * bonusRatio + (checkedIn ? 0.10 : 0.0));

    return (raw * 100).round().clamp(0, 100);
  }
}
