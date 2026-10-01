// lib/features/ai/ai_providers.dart
// Riverpod wiring. Jo providers tumhare app mein already hain (databaseProvider,
// settingsRepoProvider, streak/habit data) unhe yahan se jodo.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai/ai_repo.dart';
import '../../data/ai/remote_ai_provider.dart';
import '../../domain/ai/ai_context_builder.dart';
import '../../domain/ai/ai_models.dart';
import '../../domain/ai/ai_service.dart';
import '../../domain/ai/offline_ai_provider.dart';
import '../../core/providers.dart'; // <- databaseProvider, settingsRepoProvider, aiDataSourceProvider

// ---------- consent ----------
class AiConsentNotifier extends AsyncNotifier<AiConsent> {
  @override
  Future<AiConsent> build() async =>
      AiConsent.parse(await ref.read(settingsRepoProvider).get('ai_consent'));

  Future<void> set(AiConsent c) async {
    await ref.read(settingsRepoProvider).set('ai_consent', c.name);
    state = AsyncData(c);
  }
}

final aiConsentProvider =
    AsyncNotifierProvider<AiConsentNotifier, AiConsent>(AiConsentNotifier.new);

// ---------- core ----------
final aiRepoProvider = Provider((ref) => AiRepo(ref.watch(databaseProvider)));

final aiPayloadFactoryProvider =
    Provider((ref) => AiPayloadFactory(ref.watch(aiDataSourceProvider)));

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(
    offline: const OfflineAiProvider(),
    remote: RemoteAiProvider(),
    consent: () async =>
        AiConsent.parse(await ref.read(settingsRepoProvider).get('ai_consent')),
    cache: DriftAiCache(ref.watch(databaseProvider)),
  );
});

// ---------- features ----------
Future<AiResult> _run(Ref ref, AiFeature f, String key, {bool force = false}) async {
  final consent = await ref.read(aiConsentProvider.future);
  final payload = await ref.read(aiPayloadFactoryProvider).build(f, consent);
  return ref.read(aiServiceProvider).run(f, payload, cacheKey: key, force: force);
}

final aiWeeklyProvider = FutureProvider<AiResult>(
  (ref) => _run(ref, AiFeature.weeklyCoach, AiKeys.weekly(DateTime.now())),
);

final aiNightProvider = FutureProvider<AiResult>(
  (ref) => _run(ref, AiFeature.nightInsight, AiKeys.night(DateTime.now())),
);

final aiGoalsProvider = FutureProvider<AiResult>((ref) async {
  final res = await _run(ref, AiFeature.goalSuggestions, AiKeys.goals(DateTime.now()));
  await ref
      .read(aiRepoProvider)
      .saveSuggestions(mondayIso(DateTime.now()), res.suggestions);
  return res;
});

/// "Dobara banao" button: cache bypass karke naya result banata hai.
Future<void> regenerate(WidgetRef ref, AiFeature f) async {
  final now = DateTime.now();
  final key = switch (f) {
    AiFeature.weeklyCoach => AiKeys.weekly(now),
    AiFeature.goalSuggestions => AiKeys.goals(now),
    _ => AiKeys.night(now),
  };
  final consent = await ref.read(aiConsentProvider.future);
  final payload = await ref.read(aiPayloadFactoryProvider).build(f, consent);
  await ref.read(aiServiceProvider).run(f, payload, cacheKey: key, force: true);
  switch (f) {
    case AiFeature.weeklyCoach:
      ref.invalidate(aiWeeklyProvider);
    case AiFeature.goalSuggestions:
      ref.invalidate(aiGoalsProvider);
    default:
      ref.invalidate(aiNightProvider);
  }
}

// ---------- chat ----------
class ChatController extends AsyncNotifier<List<ChatTurn>> {
  @override
  Future<List<ChatTurn>> build() => ref.read(aiRepoProvider).chatHistory();

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final repo = ref.read(aiRepoProvider);
    final history = [...(state.valueOrNull ?? const <ChatTurn>[]), ChatTurn('user', t)];
    state = AsyncData(history);
    await repo.addChat('user', t);

    final consent = await ref.read(aiConsentProvider.future);
    final payload = await ref.read(aiPayloadFactoryProvider).build(AiFeature.chat, consent);
    final res = await ref.read(aiServiceProvider).run(AiFeature.chat, payload, history: history);

    await repo.addChat('assistant', res.text);
    state = AsyncData([...history, ChatTurn('assistant', res.text)]);
  }

  Future<void> clear() async {
    await ref.read(aiRepoProvider).clearChat();
    state = const AsyncData([]);
  }
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, List<ChatTurn>>(ChatController.new);

/// Consent screen ka "kya bheja jata hai?" preview
Future<String> payloadPreview(WidgetRef ref) async {
  final consent = await ref.read(aiConsentProvider.future);
  final p = await ref.read(aiPayloadFactoryProvider).build(AiFeature.weeklyCoach, consent);
  return const JsonEncoder.withIndent('  ').convert(p);
}
