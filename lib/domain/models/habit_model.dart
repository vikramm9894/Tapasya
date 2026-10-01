/// Domain entity representing a habit in Tapasya.
class HabitModel {
  final String id;
  final String name;
  final String category; // 'Study', 'Fitness', 'Health', 'Mindset', 'Work'
  final String kind;     // 'check', 'count', 'duration'
  final double targetValue;
  final double minValue; // Bare Minimum Mode fallback
  final String? unit;    // 'pages', 'min', 'km', etc.
  final int difficulty;  // 1: easy (10 XP), 2: medium (20 XP), 3: hard (30 XP)
  final String? cueText; // Habit stacking cue: "After morning chai..."
  final String? cueTime; // "07:30"
  final bool isActive;
  final int sortOrder;
  final String? archivedAt;

  const HabitModel({
    required this.id,
    required this.name,
    required this.category,
    this.kind = 'check',
    this.targetValue = 1.0,
    this.minValue = 1.0,
    this.unit,
    this.difficulty = 2,
    this.cueText,
    this.cueTime,
    this.isActive = true,
    this.sortOrder = 0,
    this.archivedAt,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    String? category,
    String? kind,
    double? targetValue,
    double? minValue,
    String? unit,
    int? difficulty,
    String? cueText,
    String? cueTime,
    bool? isActive,
    int? sortOrder,
    String? archivedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      kind: kind ?? this.kind,
      targetValue: targetValue ?? this.targetValue,
      minValue: minValue ?? this.minValue,
      unit: unit ?? this.unit,
      difficulty: difficulty ?? this.difficulty,
      cueText: cueText ?? this.cueText,
      cueTime: cueTime ?? this.cueTime,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
