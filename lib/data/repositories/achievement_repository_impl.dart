import 'dart:async';
import '../../domain/models/achievement_model.dart';
import '../../domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final Map<String, AchievementModel> _achievements = {
    'streak_7': const AchievementModel(
      key: 'streak_7',
      title: '7-Day Unbroken Streak',
      description: 'Conquered the first critical week of Tapasya without failing.',
      iconGlyph: '🔥',
      xpReward: 50,
      isUnlocked: true,
    ),
    'phoenix_recovery': const AchievementModel(
      key: 'phoenix_recovery',
      title: 'Phoenix Recovery',
      description: 'Overcame a miss with 2 consecutive success days to save your streak.',
      iconGlyph: '🦅',
      xpReward: 60,
      isUnlocked: true,
    ),
    'bare_min_hero': const AchievementModel(
      key: 'bare_min_hero',
      title: 'Bare Minimum Hero',
      description: 'Used Bare Minimum Mode on a tough day instead of giving up.',
      iconGlyph: '🛡️',
      xpReward: 40,
      isUnlocked: true,
    ),
    'focus_50h': const AchievementModel(
      key: 'focus_50h',
      title: '50 Deep Focus Hours',
      description: 'Dedicated 50 cumulative hours of tracked deep work.',
      iconGlyph: '⏱️',
      xpReward: 100,
      isUnlocked: false,
    ),
    'streak_30': const AchievementModel(
      key: 'streak_30',
      title: '30-Day Warrior',
      description: 'Crossed the one-third milestone of your Tapasya mission.',
      iconGlyph: '⚡',
      xpReward: 150,
      isUnlocked: false,
    ),
    'streak_90': const AchievementModel(
      key: 'streak_90',
      title: 'Tapasvi Supreme',
      description: 'Completed the full 90-day disciplined transformation.',
      iconGlyph: '👑',
      xpReward: 500,
      isUnlocked: false,
    ),
  };

  final StreamController<List<AchievementModel>> _streamController =
      StreamController<List<AchievementModel>>.broadcast();

  @override
  Stream<List<AchievementModel>> watchAchievements() async* {
    yield _achievements.values.toList();
    yield* _streamController.stream;
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    return _achievements.values.toList();
  }

  @override
  Future<void> unlockAchievement(String key) async {
    final existing = _achievements[key];
    if (existing != null && !existing.isUnlocked) {
      _achievements[key] = existing.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _streamController.add(_achievements.values.toList());
    }
  }

  void dispose() {
    _streamController.close();
  }
}
