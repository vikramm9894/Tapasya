/// Domain entity representing a study or deep work subject.
class SubjectModel {
  final String id;
  final String name;
  final String colorHex;
  final String? examDate; // 'YYYY-MM-DD'

  const SubjectModel({
    required this.id,
    required this.name,
    this.colorHex = '#00E5FF',
    this.examDate,
  });

  bool get hasExam => examDate != null && examDate!.isNotEmpty;

  SubjectModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? examDate,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      examDate: examDate ?? this.examDate,
    );
  }
}
