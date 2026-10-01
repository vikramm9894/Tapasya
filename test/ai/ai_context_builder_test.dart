import 'package:flutter_test/flutter_test.dart';
import 'package:tapasya/domain/ai/ai_context_builder.dart'; // package naam apne pubspec se match karo
import 'package:tapasya/domain/ai/ai_models.dart';

AiDay day(String date, {String? win}) => AiDay(
      date: date, mode: 'normal', score: 80, mood: 4, energy: 3, focus: 4,
      sleepHours: 7.0, win: win, issue: 'mail me at a@b.com', tomorrow: 'call 9876543210',
    );

Map<String, dynamic> build(AiConsent c, {List<AiDay>? days}) => AiContextBuilder.build(
      feature: AiFeature.weeklyCoach, consent: c, dayNumber: 10, lengthDays: 90,
      streak: 5, level: 2, days: days ?? [day('2026-09-28', win: 'finished DBMS')],
      habits: const [AiHabit(id: '1', name: 'Study', difficulty: 2, rate7: 0.7, rate14: 0.66)],
      whyText: 'Apne liye',
    );

void main() {
  test('aggregates mode mein journal/why nahi jata', () {
    final p = build(AiConsent.aggregates);
    final d = (p['days'] as List).first as Map;
    expect(d.containsKey('win'), isFalse);
    expect(d.containsKey('issue'), isFalse);
    expect(p.containsKey('why'), isFalse);
  });

  test('off mode bhi journal nahi bhejta', () {
    final p = build(AiConsent.off);
    expect(p.containsKey('why'), isFalse);
    expect(((p['days'] as List).first as Map).containsKey('win'), isFalse);
  });

  test('journal mode mein email/phone redact hote hain', () {
    final p = build(AiConsent.aggregatesAndJournal);
    final d = (p['days'] as List).first as Map;
    expect(d['issue'], contains('[email]'));
    expect(d['tomorrow'], contains('[number]'));
    expect(p['why'], 'Apne liye');
  });

  test('sirf last 14 din aur weekday sahi', () {
    final days = [for (var i = 1; i <= 20; i++) day('2026-09-${i.toString().padLeft(2, '0')}')];
    final p = build(AiConsent.aggregates, days: days);
    expect((p['days'] as List).length, 14);
    expect(AiContextBuilder.weekday('2026-09-28'), 'Mon');
  });

  test('week key Monday par snap hoti hai', () {
    expect(mondayIso(DateTime(2026, 10, 1)), '2026-09-28'); // Thursday
    expect(mondayIso(DateTime(2026, 9, 28)), '2026-09-28');
    expect(mondayIso(DateTime(2026, 10, 4)), '2026-09-28'); // Sunday
  });
}
