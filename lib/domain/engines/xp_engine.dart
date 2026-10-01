/// Pure Dart XP and Level Progression Engine for Tapasya.
class XpEngine {
  const XpEngine._();

  static const int dailyCap = 300;
  static const int perfectDayBonus = 40;

  /// Base XP by difficulty level:
  /// - 1 (Easy): 10 XP
  /// - 2 (Medium): 20 XP
  /// - 3 (Hard): 30 XP
  ///
  /// Modifiers:
  /// - [isNonNeg]: 1.5x multiplier
  /// - [isBareMin]: 0.5x multiplier
  static int calculateHabitXp(
    int difficulty, {
    bool isNonNeg = false,
    bool isBareMin = false,
  }) {
    final double base = switch (difficulty) {
      1 => 10.0,
      3 => 30.0,
      _ => 20.0,
    };

    var xp = base;
    if (isNonNeg) xp *= 1.5;
    if (isBareMin) xp *= 0.5;

    return xp.round();
  }

  /// Calculates XP required to advance from [level] to [level + 1].
  /// Formula: 500 + 150 * (level - 1)
  /// L1 -> L2 = 500
  /// L2 -> L3 = 650
  /// L3 -> L4 = 800
  static int xpToNext(int level) {
    if (level < 1) return 500;
    return 500 + 150 * (level - 1);
  }

  /// Maps total accumulated XP into current level, remaining XP into current level,
  /// XP needed for next level, and title.
  static ({int level, int into, int need, String title}) levelFor(int totalXp) {
    var level = 1;
    var left = totalXp < 0 ? 0 : totalXp;

    while (left >= xpToNext(level)) {
      left -= xpToNext(level);
      level++;
    }

    final title = switch (level) {
      >= 20 => 'Tapasvi (तपस्वी)',
      >= 15 => 'Blizzard Master',
      >= 10 => 'Snow Warrior',
      >= 5  => 'Ice Walker',
      _     => 'Frost Rookie',
    };

    return (
      level: level,
      into: left,
      need: xpToNext(level),
      title: title,
    );
  }
}
