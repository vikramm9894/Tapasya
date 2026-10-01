// lib/data/ai/ai_tables.dart
// Drift tables. Inhe @DriftDatabase(tables: [...]) mein add karo, schemaVersion +1 karo.
import 'package:drift/drift.dart';

class AiInsights extends Table {
  TextColumn get key => text()(); // weekly:2026-09-28 / night:2026-10-01 / goals:...
  TextColumn get body => text()(); // AiResult JSON
  TextColumn get createdOn => text()(); // local 'YYYY-MM-DD'
  @override
  Set<Column> get primaryKey => {key};
}

class AiChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()(); // user | assistant
  TextColumn get content => text()();
  TextColumn get createdOn => text()();
  IntColumn get ts => integer()(); // epoch ms (sirf ordering ke liye)
}

class AiSuggestionRows extends Table {
  @override
  String get tableName => 'ai_suggestions';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get weekKey => text()(); // Monday ISO date
  TextColumn get habitId => text()();
  TextColumn get kind => text()(); // increase | decrease | keep
  RealColumn get changePct => real()();
  TextColumn get reason => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  @override
  List<Set<Column>> get uniqueKeys => [
        {weekKey, habitId},
      ];
}

/* Migration (apne AppDatabase mein):

  @override
  int get schemaVersion => <purana + 1>;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < <purana + 1>) {
            await m.createTable(aiInsights);
            await m.createTable(aiChatMessages);
            await m.createTable(aiSuggestionRows);
          }
        },
      );

  Kabhi koi table drop mat karna. Settings table mein key 'ai_consent' use hoti hai.
*/
