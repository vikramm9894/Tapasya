import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/daily_log_repository_impl.dart';
import '../../../domain/models/checkin_model.dart';
import '../../../domain/models/daily_log_model.dart';
import '../../../domain/repositories/daily_log_repository.dart';

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DailyLogRepositoryImpl();
});

final todayLogProvider = StreamProvider<DailyLogModel?>((ref) {
  final repo = ref.watch(dailyLogRepositoryProvider);
  final today = AppDateUtils.todayKey();
  return repo.watchDailyLog(today);
});

final todayCheckinProvider = StreamProvider<CheckinModel?>((ref) {
  final repo = ref.watch(dailyLogRepositoryProvider);
  final today = AppDateUtils.todayKey();
  return repo.watchCheckin(today);
});

final todayPrioritiesProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(dailyLogRepositoryProvider);
  final today = AppDateUtils.todayKey();
  return repo.watchPrioritiesForDate(today);
});
