import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../domain/ai/ai_context_builder.dart';
import '../domain/engines/streak_engine.dart';
import '../domain/engines/xp_engine.dart';

/// AppDatabase singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Settings repository managing key-value pairs (like 'ai_consent').
class SettingsRepo {
  final AppDatabase db;
  SettingsRepo(this.db);

  Future<String?> get(String key) async {
    final row = await (db.select(db.settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await db.into(db.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }
}

final settingsRepoProvider = Provider<SettingsRepo>((ref) {
  return SettingsRepo(ref.watch(databaseProvider));
});

/// Concrete Drift implementation of AiDataSource for feeding the AI layer.
class DriftAiDataSource implements AiDataSource {
  final AppDatabase db;
  DriftAiDataSource(this.db);

  @override
  Future<List<AiDay>> lastDays(int n) async {
    final logs = await (db.select(db.dailyLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(n))
        .get();

    final result = <AiDay>[];
    for (final log in logs.reversed) {
      final checkin = await (db.select(db.checkins)..where((t) => t.date.equals(log.date))).getSingleOrNull();
      result.add(
        AiDay(
          date: log.date,
          mode: log.mode,
          score: log.score,
          mood: checkin?.mood,
          energy: checkin?.energy,
          focus: checkin?.focus,
          sleepHours: checkin?.sleepHours,
          win: checkin?.win,
          issue: checkin?.issue,
          tomorrow: checkin?.tomorrow,
        ),
      );
    }
    return result;
  }

  @override
  Future<List<AiHabit>> activeHabits() async {
    final habits = await (db.select(db.habits)..where((t) => t.isActive.equals(true))).get();
    final out = <AiHabit>[];

    for (final h in habits) {
      final entries = await (db.select(db.habitEntries)..where((t) => t.habitId.equals(h.id))).get();
      final totalEntries = entries.length;
      final completedEntries = entries.where((e) => e.completed).length;

      final rate7 = totalEntries > 0 ? (completedEntries / totalEntries.clamp(1, 7)).clamp(0.0, 1.0) : 0.8;
      final rate14 = totalEntries > 0 ? (completedEntries / totalEntries.clamp(1, 14)).clamp(0.0, 1.0) : 0.75;

      out.add(
        AiHabit(
          id: h.id,
          name: h.name,
          difficulty: h.difficulty,
          rate7: rate7,
          rate14: rate14,
        ),
      );
    }
    return out;
  }

  @override
  Future<int> streak() async {
    final logs = await (db.select(db.dailyLogs)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();
    final dayStates = logs.map((l) {
      switch (l.mode) {
        case 'bare_min':
          return DayState.success;
        case 'rest':
          return DayState.rest;
        case 'freeze':
          return DayState.freeze;
        case 'miss':
          return DayState.miss;
        default:
          return l.score >= 70 ? DayState.success : DayState.miss;
      }
    }).toList();
    return StreakEngine.currentStreak(dayStates);
  }

  @override
  Future<int> level() async {
    final events = await db.select(db.xpEvents).get();
    final totalXp = events.fold<int>(0, (sum, e) => sum + e.amount);
    return XpEngine.levelFor(totalXp).level;
  }

  @override
  Future<int> dayNumber() async {
    final journey = await (db.select(db.journeys)..where((t) => t.status.equals('active'))).getSingleOrNull();
    if (journey == null) return 1;
    final start = DateTime.tryParse(journey.startDate) ?? DateTime.now();
    return DateTime.now().difference(start).inDays + 1;
  }

  @override
  Future<int> lengthDays() async {
    final journey = await (db.select(db.journeys)..where((t) => t.status.equals('active'))).getSingleOrNull();
    return journey?.lengthDays ?? 90;
  }

  @override
  Future<String?> whyText() async {
    final journey = await (db.select(db.journeys)..where((t) => t.status.equals('active'))).getSingleOrNull();
    return journey?.whyText;
  }
}

final aiDataSourceProvider = Provider<AiDataSource>((ref) {
  return DriftAiDataSource(ref.watch(databaseProvider));
});
