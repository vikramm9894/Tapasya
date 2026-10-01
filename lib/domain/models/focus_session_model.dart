/// Domain entity representing a tracked focus or Pomodoro session.
class FocusSessionModel {
  final String id;
  final String? subjectId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final bool completed;

  const FocusSessionModel({
    required this.id,
    this.subjectId,
    required this.startedAt,
    this.endedAt,
    required this.durationSec,
    this.completed = false,
  });

  FocusSessionModel copyWith({
    String? id,
    String? subjectId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    bool? completed,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      completed: completed ?? this.completed,
    );
  }
}
