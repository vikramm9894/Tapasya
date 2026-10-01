import '../models/checkin_model.dart';
import '../models/daily_log_model.dart';

abstract class DailyLogRepository {
  Stream<DailyLogModel?> watchDailyLog(String date);
  Future<DailyLogModel?> getDailyLog(String date);
  Future<void> saveDailyLog(DailyLogModel log);
  Stream<List<DailyLogModel>> watchAllLogs();
  Future<List<DailyLogModel>> getAllLogs();

  // Checkins
  Stream<CheckinModel?> watchCheckin(String date);
  Future<CheckinModel?> getCheckin(String date);
  Future<void> saveCheckin(CheckinModel checkin);

  // Daily Priorities (Top 3)
  Stream<List<String>> watchPrioritiesForDate(String date);
  Future<List<String>> getPrioritiesForDate(String date);
  Future<void> setPrioritiesForDate(String date, List<String> habitIds);
}
