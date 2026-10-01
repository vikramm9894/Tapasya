import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../tables/schema.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Journeys,
  Habits,
  HabitEntries,
  DailyPriorities,
  DailyLogs,
  Checkins,
  Subjects,
  ExamTopics,
  FocusSessions,
  XpEvents,
  Freezes,
  Challenges,
  ChallengeDays,
  Achievements,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Schema migrations will be incremented sequentially.
        // Never drop tables in production.
      },
      beforeOpen: (details) async {
        // Enable foreign key constraints in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tapasya.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
