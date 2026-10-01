import 'dart:async';
import '../../domain/models/checkin_model.dart';
import '../../domain/models/daily_log_model.dart';
import '../../domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final Map<String, DailyLogModel> _logs = {};
  final Map<String, CheckinModel> _checkins = {};
  final Map<String, List<String>> _priorities = {};

  final StreamController<Map<String, DailyLogModel>> _logsController =
      StreamController<Map<String, DailyLogModel>>.broadcast();
  final StreamController<Map<String, CheckinModel>> _checkinsController =
      StreamController<Map<String, CheckinModel>>.broadcast();
  final StreamController<Map<String, List<String>>> _prioritiesController =
      StreamController<Map<String, List<String>>>.broadcast();

  @override
  Stream<DailyLogModel?> watchDailyLog(String date) async* {
    yield _logs[date];
    yield* _logsController.stream.map((map) => map[date]);
  }

  @override
  Future<DailyLogModel?> getDailyLog(String date) async {
    return _logs[date];
  }

  @override
  Future<void> saveDailyLog(DailyLogModel log) async {
    _logs[log.date] = log;
    _logsController.add(_logs);
  }

  @override
  Stream<List<DailyLogModel>> watchAllLogs() async* {
    yield _logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    yield* _logsController.stream
        .map((map) => map.values.toList()..sort((a, b) => a.date.compareTo(b.date)));
  }

  @override
  Future<List<DailyLogModel>> getAllLogs() async {
    return _logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Stream<CheckinModel?> watchCheckin(String date) async* {
    yield _checkins[date];
    yield* _checkinsController.stream.map((map) => map[date]);
  }

  @override
  Future<CheckinModel?> getCheckin(String date) async {
    return _checkins[date];
  }

  @override
  Future<void> saveCheckin(CheckinModel checkin) async {
    _checkins[checkin.date] = checkin;
    _checkinsController.add(_checkins);
  }

  @override
  Stream<List<String>> watchPrioritiesForDate(String date) async* {
    yield _priorities[date] ?? [];
    yield* _prioritiesController.stream.map((map) => map[date] ?? []);
  }

  @override
  Future<List<String>> getPrioritiesForDate(String date) async {
    return _priorities[date] ?? [];
  }

  @override
  Future<void> setPrioritiesForDate(String date, List<String> habitIds) async {
    _priorities[date] = habitIds.take(3).toList();
    _prioritiesController.add(_priorities);
  }

  void dispose() {
    _logsController.close();
    _checkinsController.close();
    _prioritiesController.close();
  }
}
