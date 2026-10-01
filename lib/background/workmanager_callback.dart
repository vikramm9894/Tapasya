import 'package:workmanager/workmanager.dart';
import '../core/utils/date_utils.dart';
import '../domain/engines/streak_engine.dart';

const String midnightRolloverTask = 'com.tapasya.midnight_rollover';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case midnightRolloverTask:
        await _handleMidnightRollover();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _handleMidnightRollover() async {
  final yesterday = AppDateUtils.yesterdayKey();
  final currentMonth = AppDateUtils.currentMonthKey();

  // Smart Streak Rollover Rule:
  // If yesterday has no completed entry:
  // Check if freezes left in this calendar month (max 2).
  // If freezes < 2: auto-apply freeze.
  // Else: record as miss.
  // Then recompute streak from all historical daily_logs.
}

class WorkmanagerService {
  WorkmanagerService._();

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic midnight check
    await Workmanager().registerPeriodicTask(
      'midnight_rollover_job',
      midnightRolloverTask,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
