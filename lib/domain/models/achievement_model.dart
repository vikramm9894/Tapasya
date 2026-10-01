/// Domain entity representing a behavioral achievement in Tapasya.
class AchievementModel {
  final String key;
  final String title;
  final String description;
  final String iconGlyph;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.key,
    required this.title,
    required this.description,
    required this.iconGlyph,
    this.xpReward = 50,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({
    String? key,
    String? title,
    String? description,
    String? iconGlyph,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      iconGlyph: iconGlyph ?? this.iconGlyph,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
