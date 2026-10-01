/// Domain entity representing a topic within Exam Mode.
class ExamTopicModel {
  final String id;
  final String subjectId;
  final String title;
  final bool done;
  final String? doneOn; // 'YYYY-MM-DD'

  const ExamTopicModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.done = false,
    this.doneOn,
  });

  ExamTopicModel copyWith({
    String? id,
    String? subjectId,
    String? title,
    bool? done,
    String? doneOn,
  }) {
    return ExamTopicModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      done: done ?? this.done,
      doneOn: doneOn ?? this.doneOn,
    );
  }
}
