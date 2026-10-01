// lib/domain/ai/ai_models.dart
// Pure Dart. Zero Flutter imports (strict rule #3).

enum AiConsent {
  off, // kuch bhi cloud nahi jata
  aggregates, // sirf numbers: score, rates, sleep, mood/energy/focus (1-5)
  aggregatesAndJournal; // + Why text aur night-review ki 3 lines

  static AiConsent parse(String? v) => AiConsent.values.firstWhere(
        (e) => e.name == v,
        orElse: () => AiConsent.off,
      );
}

enum AiFeature { weeklyCoach, nightInsight, goalSuggestions, chat }

class AiSuggestion {
  final String habitId;
  final String kind; // increase | decrease | keep
  final double changePct; // 0.0 - 0.25 (guard clamp karta hai)
  final String reason;
  const AiSuggestion({
    required this.habitId,
    required this.kind,
    required this.changePct,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'kind': kind,
        'changePct': changePct,
        'reason': reason,
      };

  factory AiSuggestion.fromJson(Map<String, dynamic> j) => AiSuggestion(
        habitId: '${j['habitId']}',
        kind: '${j['kind']}',
        changePct: ((j['changePct'] ?? 0) as num).toDouble(),
        reason: '${j['reason'] ?? ''}',
      );
}

class AiResult {
  final String text;
  final List<AiSuggestion> suggestions;
  final bool fromCloud;
  const AiResult({
    required this.text,
    this.suggestions = const [],
    this.fromCloud = false,
  });

  AiResult copyWith({String? text, List<AiSuggestion>? suggestions, bool? fromCloud}) =>
      AiResult(
        text: text ?? this.text,
        suggestions: suggestions ?? this.suggestions,
        fromCloud: fromCloud ?? this.fromCloud,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
        'fromCloud': fromCloud,
      };

  factory AiResult.fromJson(Map<String, dynamic> j, {bool? fromCloud}) => AiResult(
        text: '${j['text'] ?? ''}',
        suggestions: [
          for (final e in (j['suggestions'] as List? ?? const []))
            AiSuggestion.fromJson(Map<String, dynamic>.from(e as Map)),
        ],
        fromCloud: fromCloud ?? (j['fromCloud'] == true),
      );
}

class ChatTurn {
  final String role; // user | assistant
  final String content;
  const ChatTurn(this.role, this.content);
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiException implements Exception {
  final String message;
  const AiException(this.message);
  @override
  String toString() => 'AiException: $message';
}

// ---- Local-date helpers (strict rule #1: local 'YYYY-MM-DD', UTC kabhi nahi) ----
// Agar tumhare core/date_utils.dart mein ye already hain, wahi use karo.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String mondayIso(DateTime d) =>
    isoDate(DateTime(d.year, d.month, d.day - (d.weekday - 1)));

class AiKeys {
  static String weekly(DateTime d) => 'weekly:${mondayIso(d)}';
  static String goals(DateTime d) => 'goals:${mondayIso(d)}';
  static String night(DateTime d) => 'night:${isoDate(d)}';
}
