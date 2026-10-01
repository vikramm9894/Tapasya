import 'package:flutter_test/flutter_test.dart';
import 'package:tapasya/domain/ai/ai_guard.dart';
import 'package:tapasya/domain/ai/ai_models.dart';

void main() {
  test('6 ghante se kam sleep ka sujhav reject', () {
    expect(AiGuard.check(const AiResult(text: 'Kal sleep 4 ghante rakho')), isNull);
    expect(AiGuard.check(const AiResult(text: 'Aim for 5 hours of sleep')), isNull);
  });

  test('7 ghante sleep wala jawab pass', () {
    expect(AiGuard.check(const AiResult(text: 'Sleep 7 ghante rakho')), isNotNull);
  });

  test('extreme diet reject', () {
    expect(AiGuard.check(const AiResult(text: 'Try a crash diet this week')), isNull);
  });

  test('suggestion pct 25% par clamp, unknown habit drop, max 3', () {
    final r = AiResult(text: 'ok', suggestions: [
      const AiSuggestion(habitId: '1', kind: 'increase', changePct: 0.9, reason: 'a'),
      const AiSuggestion(habitId: '99', kind: 'increase', changePct: 0.1, reason: 'b'),
      const AiSuggestion(habitId: '1', kind: 'delete', changePct: 0.1, reason: 'c'),
    ]);
    final out = AiGuard.check(r, knownHabitIds: {'1'})!;
    expect(out.suggestions.length, 1);
    expect(out.suggestions.first.changePct, 0.25);
  });

  test('crisis keywords pakde jate hain', () {
    expect(AiGuard.isCrisis('mujhe jeena nahi hai'), isTrue);
    expect(AiGuard.isCrisis('I want to end my life'), isTrue);
    expect(AiGuard.isCrisis('aaj study mein mann nahi lag raha'), isFalse);
  });
}
