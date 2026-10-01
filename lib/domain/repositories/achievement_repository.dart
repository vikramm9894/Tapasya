import '../models/achievement_model.dart';

abstract class AchievementRepository {
  Stream<List<AchievementModel>> watchAchievements();
  Future<List<AchievementModel>> getAchievements();
  Future<void> unlockAchievement(String key);
}
