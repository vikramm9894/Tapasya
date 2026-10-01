import 'package:flutter_test/flutter_test.dart';
import 'package:tapasya/domain/ai/ai_models.dart';
import 'package:tapasya/domain/ai/ai_provider.dart';
import 'package:tapasya/domain/ai/ai_service.dart';
import 'package:tapasya/domain/ai/offline_ai_provider.dart';

class FakeRemote implements AiProvider {
  FakeRemote({this.result, this.error});
  final AiResult? result;
  final Object? error;
  int calls = 0;
  @override
  Future<AiResult> run(AiFeature f, Map<String, dynamic> p, {List<ChatTurn> history = const []}) async {
    calls++;
    if (error != null) throw error!;
    return result!;
  }
}

class MemCache implements AiCacheStore {
  final m = <String, AiResult>{};
  @override
  Future<AiResult?> read(String k) async => m[k];
  @override
  Future<void> write(String k, AiResult r) async => m[k] = r;
}

const payload = {
  'journey': {'day': 5, 'length': 90, 'streak': 3, 'level': 1},
  'days': [
    {'date': '2026-10-01', 'mode': 'normal', 'score': 80}
  ],
  'habits': [
    {'id': '1', 'name': 'Study', 'rate7': 0.9, 'rate14': 0.9}
  ],
};

AiService svc(AiConsent c, AiProvider? remote, {AiCacheStore? cache}) => AiService(
      offline: const OfflineAiProvider(), remote: remote, consent: () async => c, cache: cache);

void main() {
  test('consent off: cloud kabhi call nahi hota', () async {
    final r = FakeRemote(result: const AiResult(text: 'cloud'));
    final out = await svc(AiConsent.off, r).run(AiFeature.weeklyCoach, payload);
    expect(r.calls, 0);
    expect(out.fromCloud, isFalse);
  });

  test('cloud OK: result fromCloud=true', () async {
    final r = FakeRemote(result: const AiResult(text: 'Badhiya hafta'));
    final out = await svc(AiConsent.aggregates, r).run(AiFeature.weeklyCoach, payload);
    expect(out.fromCloud, isTrue);
  });

  test('cloud error: offline fallback aur cache nahi hota', () async {
    final cache = MemCache();
    final r = FakeRemote(error: Exception('no net'));
    final out = await svc(AiConsent.aggregates, r, cache: cache)
        .run(AiFeature.weeklyCoach, payload, cacheKey: 'weekly:x');
    expect(out.fromCloud, isFalse);
    expect(out.text, isNotEmpty);
    expect(cache.m, isEmpty);
  });

  test('unsafe cloud jawab (sleep 4 ghante) offline se replace', () async {
    final r = FakeRemote(result: const AiResult(text: 'Sleep 4 ghante kaafi hai'));
    final out = await svc(AiConsent.aggregates, r).run(AiFeature.weeklyCoach, payload);
    expect(out.fromCloud, isFalse);
    expect(out.text.contains('4 ghante'), isFalse);
  });

  test('crisis message cloud tak nahi jata', () async {
    final r = FakeRemote(result: const AiResult(text: 'cloud'));
    final out = await svc(AiConsent.aggregates, r).run(AiFeature.chat, payload,
        history: const [ChatTurn('user', 'mujhe jeena nahi hai')]);
    expect(r.calls, 0);
    expect(out.text, contains('14416'));
  });

  test('cache hit par dobara compute nahi', () async {
    final cache = MemCache();
    final r = FakeRemote(result: const AiResult(text: 'Badhiya hafta'));
    final s = svc(AiConsent.aggregates, r, cache: cache);
    await s.run(AiFeature.weeklyCoach, payload, cacheKey: 'weekly:x');
    await s.run(AiFeature.weeklyCoach, payload, cacheKey: 'weekly:x');
    expect(r.calls, 1);
    await s.run(AiFeature.weeklyCoach, payload, cacheKey: 'weekly:x', force: true);
    expect(r.calls, 2);
  });

  test('offline goals: 85%+ increase, 50% se kam decrease', () async {
    final p = {
      ...payload,
      'habits': [
        {'id': '1', 'name': 'Study', 'rate7': 0.9, 'rate14': 0.9},
        {'id': '2', 'name': 'Walk', 'rate7': 0.3, 'rate14': 0.3},
        {'id': '3', 'name': 'Read', 'rate7': 0.6, 'rate14': 0.6},
      ],
    };
    final out = await const OfflineAiProvider().run(AiFeature.goalSuggestions, p);
    expect(out.suggestions.map((s) => '${s.habitId}:${s.kind}'), ['1:increase', '2:decrease']);
  });
}
