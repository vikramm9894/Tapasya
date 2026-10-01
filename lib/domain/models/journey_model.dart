/// Domain entity representing a Tapasya Journey (30/60/90 days).
class JourneyModel {
  final String id;
  final String startDate; // 'YYYY-MM-DD'
  final int lengthDays;   // 30, 60, 90
  final String? whyText;  // "Main ye kyun kar raha hoon"
  final String? letterText; // Day-90 letter to future self (locked until completion)
  final String status;    // 'active', 'completed', 'abandoned'
  final String theme;

  const JourneyModel({
    required this.id,
    required this.startDate,
    this.lengthDays = 90,
    this.whyText,
    this.letterText,
    this.status = 'active',
    this.theme = 'default',
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  JourneyModel copyWith({
    String? id,
    String? startDate,
    int? lengthDays,
    String? whyText,
    String? letterText,
    String? status,
    String? theme,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      lengthDays: lengthDays ?? this.lengthDays,
      whyText: whyText ?? this.whyText,
      letterText: letterText ?? this.letterText,
      status: status ?? this.status,
      theme: theme ?? this.theme,
    );
  }
}
