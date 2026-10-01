// lib/data/ai/ai_repo.dart
// `AppDatabase` ko apne database class ke naam se badlo.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/ai/ai_models.dart';
import '../../domain/ai/ai_service.dart';
import '../database/app_database.dart';

class DriftAiCache implements AiCacheStore {
  DriftAiCache(this.db);
  final AppDatabase db;

  @override
  Future<AiResult?> read(String key) async {
    final row =
        await (db.select(db.aiInsights)..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    return AiResult.fromJson(jsonDecode(row.body) as Map<String, dynamic>);
  }

  @override
  Future<void> write(String key, AiResult r) => db.into(db.aiInsights).insertOnConflictUpdate(
        AiInsightsCompanion.insert(
          key: key,
          body: jsonEncode(r.toJson()),
          createdOn: isoDate(DateTime.now()),
        ),
      );
}

class AiRepo {
  AiRepo(this.db);
  final AppDatabase db;

  // ---- chat ----
  Future<List<ChatTurn>> chatHistory({int limit = 50}) async {
    final rows = await (db.select(db.aiChatMessages)
          ..orderBy([(t) => OrderingTerm.desc(t.ts)])
          ..limit(limit))
        .get();
    return [for (final r in rows.reversed) ChatTurn(r.role, r.content)];
  }

  Future<void> addChat(String role, String content) => db.into(db.aiChatMessages).insert(
        AiChatMessagesCompanion.insert(
          role: role,
          content: content,
          createdOn: isoDate(DateTime.now()),
          ts: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<void> clearChat() => db.delete(db.aiChatMessages).go();

  // ---- suggestions (kabhi auto-apply nahi) ----
  Future<void> saveSuggestions(String weekKey, List<AiSuggestion> list) async {
    for (final s in list) {
      await db.into(db.aiSuggestionRows).insert(
            AiSuggestionRowsCompanion.insert(
              weekKey: weekKey,
              habitId: s.habitId,
              kind: s.kind,
              changePct: s.changePct,
              reason: s.reason,
            ),
            mode: InsertMode.insertOrIgnore, // purana accept/dismiss status na bigde
          );
    }
  }

  Stream<List<AiSuggestionRow>> pending(String weekKey) => (db.select(db.aiSuggestionRows)
        ..where((t) => t.weekKey.equals(weekKey) & t.status.equals('pending')))
      .watch();

  Future<void> setStatus(int id, String status) => (db.update(db.aiSuggestionRows)
        ..where((t) => t.id.equals(id)))
      .write(AiSuggestionRowsCompanion(status: Value(status)));
}
