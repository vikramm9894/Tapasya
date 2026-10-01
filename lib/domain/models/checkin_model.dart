/// Domain model representing the Evening Reflection & Checkin.
class CheckinModel {
  final String date; // 'YYYY-MM-DD'
  final int mood;    // 1 - 5
  final int energy;  // 1 - 5
  final int focus;   // 1 - 5
  final double sleepHours; // min 6.0
  final String? win;
  final String? issue;
  final String? tomorrow;

  const CheckinModel({
    required this.date,
    this.mood = 3,
    this.energy = 3,
    this.focus = 3,
    this.sleepHours = 7.0,
    this.win,
    this.issue,
    this.tomorrow,
  });

  CheckinModel copyWith({
    String? date,
    int? mood,
    int? energy,
    int? focus,
    double? sleepHours,
    String? win,
    String? issue,
    String? tomorrow,
  }) {
    return CheckinModel(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      focus: focus ?? this.focus,
      sleepHours: sleepHours ?? this.sleepHours,
      win: win ?? this.win,
      issue: issue ?? this.issue,
      tomorrow: tomorrow ?? this.tomorrow,
    );
  }
}
