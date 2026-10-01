// lib/domain/ai/ai_context_builder.dart
// Pure Dart. Yahi file decide karti hai ki cloud ko KYA bheja ja sakta hai.
import 'ai_models.dart';

class AiDay {
  final String date; // 'YYYY-MM-DD' local
  final String mode; // normal | bare_min | rest | freeze
  final int score; // 0-100
  final int? mood, energy, focus; // 1-5
  final double? sleepHours;
  final String? win, issue, tomorrow; // journal lines (sirf journal consent par)
  const AiDay({
    required this.date,
    required this.mode,
    required this.score,
    this.mood,
    this.energy,
    this.focus,
    this.sleepHours,
    this.win,
    this.issue,
    this.tomorrow,
  });
}

class AiHabit {
  final String id;
  final String name;
  final int difficulty; // 1-3
  final double rate7, rate14; // 0.0 - 1.0
  final String? worstWeekday; // 'Sun'
  const AiHabit({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.rate7,
    required this.rate14,
    this.worstWeekday,
  });
}

/// App is interface ko apne DAOs/engines se implement karta hai.
abstract class AiDataSource {
  Future<List<AiDay>> lastDays(int n); // purane se naye, aaj tak
  Future<List<AiHabit>> activeHabits();
  Future<int> streak(); // StreakEngine se derive, stored counter nahi
  Future<int> level();
  Future<int> dayNumber();
  Future<int> lengthDays();
  Future<String?> whyText(); // letter_text yahan kabhi nahi aata
}

class AiContextBuilder {
  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final _phone = RegExp(r'\+?\d[\d\s-]{8,}\d');

  static String weekday(String iso) => _wd[DateTime.parse(iso).weekday - 1];

  static String redact(String s, {int max = 280}) {
    var t = s.replaceAll(_email, '[email]').replaceAll(_phone, '[number]').trim();
    if (t.length > max) t = t.substring(0, max);
    return t;
  }

  /// consent == off ho tab bhi numbers wala payload banta hai (offline provider ko
  /// chahiye), par AiService off par kabhi cloud ko call nahi karta.
  static Map<String, dynamic> build({
    required AiFeature feature,
    required AiConsent consent,
    required int dayNumber,
    required int lengthDays,
    required int streak,
    required int level,
    required List<AiDay> days,
    required List<AiHabit> habits,
    String? whyText,
  }) {
    final journal = consent == AiConsent.aggregatesAndJournal;
    final recent = days.length > 14 ? days.sublist(days.length - 14) : days;
    return {
      'feature': feature.name,
      'consent': consent.name,
      'journey': {'day': dayNumber, 'length': lengthDays, 'streak': streak, 'level': level},
      'days': [
        for (final d in recent)
          {
            'date': d.date,
            'weekday': weekday(d.date),
            'mode': d.mode,
            'score': d.score,
            if (d.mood != null) 'mood': d.mood,
            if (d.energy != null) 'energy': d.energy,
            if (d.focus != null) 'focus': d.focus,
            if (d.sleepHours != null) 'sleep': d.sleepHours,
            if (journal && d.win != null && d.win!.trim().isNotEmpty) 'win': redact(d.win!),
            if (journal && d.issue != null && d.issue!.trim().isNotEmpty)
              'issue': redact(d.issue!),
            if (journal && d.tomorrow != null && d.tomorrow!.trim().isNotEmpty)
              'tomorrow': redact(d.tomorrow!),
          },
      ],
      'habits': [
        for (final h in habits)
          {
            'id': h.id,
            'name': h.name,
            'difficulty': h.difficulty,
            'rate7': double.parse(h.rate7.toStringAsFixed(2)),
            'rate14': double.parse(h.rate14.toStringAsFixed(2)),
            if (h.worstWeekday != null) 'worstWeekday': h.worstWeekday,
          },
      ],
      if (journal && whyText != null && whyText.trim().isNotEmpty)
        'why': redact(whyText, max: 400),
    };
  }
}

/// Feature + consent se poora payload banata hai (UI aur background job dono yahi use karein).
class AiPayloadFactory {
  AiPayloadFactory(this.source);
  final AiDataSource source;

  Future<Map<String, dynamic>> build(AiFeature feature, AiConsent consent) async {
    final days = await source.lastDays(14);
    final habits = await source.activeHabits();
    final why = consent == AiConsent.aggregatesAndJournal ? await source.whyText() : null;
    return AiContextBuilder.build(
      feature: feature,
      consent: consent,
      dayNumber: await source.dayNumber(),
      lengthDays: await source.lengthDays(),
      streak: await source.streak(),
      level: await source.level(),
      days: days,
      habits: habits,
      whyText: why,
    );
  }
}
