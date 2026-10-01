/// Domain model representing a summarized day in Tapasya.
class DailyLogModel {
  final String date; // 'YYYY-MM-DD' local timezone
  final String? journeyId;
  final String mode; // 'normal', 'bare_min', 'rest', 'freeze'
  final int score;   // 0 - 100
  final int xpEarned;

  const DailyLogModel({
    required this.date,
    this.journeyId,
    this.mode = 'normal',
    this.score = 0,
    this.xpEarned = 0,
  });

  bool get isSuccess => mode == 'bare_min' || score >= 70;
  bool get isRest => mode == 'rest';
  bool get isFreeze => mode == 'freeze';

  DailyLogModel copyWith({
    String? date,
    String? journeyId,
    String? mode,
    int? score,
    int? xpEarned,
  }) {
    return DailyLogModel(
      date: date ?? this.date,
      journeyId: journeyId ?? this.journeyId,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}
