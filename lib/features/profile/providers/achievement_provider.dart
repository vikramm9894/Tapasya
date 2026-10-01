import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../../../domain/models/achievement_model.dart';
import '../../../domain/repositories/achievement_repository.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepositoryImpl();
});

final achievementsProvider = StreamProvider<List<AchievementModel>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.watchAchievements();
});
