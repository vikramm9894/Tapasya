/// Domain model representing active or available consistency challenges and Boss Battles.
class ChallengeModel {
  final String id;
  final String title;
  final String subtitle;
  final String kind; // '7d', '30d', 'weekly_boss', 'custom'
  final int targetCount;
  final int currentCount;
  final int xpReward;
  final String badgeKey;
  final bool isCompleted;
  final String? bossName;
  final int? bossMaxHp;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.targetCount,
    this.currentCount = 0,
    required this.xpReward,
    required this.badgeKey,
    this.isCompleted = false,
    this.bossName,
    this.bossMaxHp,
  });

  double get progressRatio => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
  bool get canClaim => currentCount >= targetCount && !isCompleted;

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? kind,
    int? targetCount,
    int? currentCount,
    int? xpReward,
    String? badgeKey,
    bool? isCompleted,
    String? bossName,
    int? bossMaxHp,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      kind: kind ?? this.kind,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      xpReward: xpReward ?? this.xpReward,
      badgeKey: badgeKey ?? this.badgeKey,
      isCompleted: isCompleted ?? this.isCompleted,
      bossName: bossName ?? this.bossName,
      bossMaxHp: bossMaxHp ?? this.bossMaxHp,
    );
  }
}
