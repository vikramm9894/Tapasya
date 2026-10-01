// lib/domain/ai/ai_service.dart
// Hybrid brain: offline default, cloud sirf opt-in par, har failure par offline fallback.
import 'ai_guard.dart';
import 'ai_models.dart';
import 'ai_provider.dart';

abstract class AiCacheStore {
  Future<AiResult?> read(String key);
  Future<void> write(String key, AiResult r);
}

class AiService {
  AiService({
    required this.offline,
    required this.consent,
    this.remote,
    this.cache,
    this.remoteTimeout = const Duration(seconds: 30),
  });

  final AiProvider offline;
  final AiProvider? remote;
  final Future<AiConsent> Function() consent;
  final AiCacheStore? cache;
  final Duration remoteTimeout;

  Future<AiResult> run(
    AiFeature feature,
    Map<String, dynamic> payload, {
    List<ChatTurn> history = const [],
    String? cacheKey, // weekly/night/goals ke liye; chat ke liye null
    bool force = false, // "Dobara banao" button
  }) async {
    if (cacheKey != null && !force) {
      final hit = await cache?.read(cacheKey);
      if (hit != null) return hit;
    }
    final (result, degraded) = await _compute(feature, payload, history);
    // Network fail wale offline result ko cache mat karo, taaki next try cloud se ho.
    if (cacheKey != null && !degraded) await cache?.write(cacheKey, result);
    return result;
  }

  Future<(AiResult, bool)> _compute(
    AiFeature feature,
    Map<String, dynamic> payload,
    List<ChatTurn> history,
  ) async {
    if (feature == AiFeature.chat &&
        history.isNotEmpty &&
        AiGuard.isCrisis(history.last.content)) {
      return (AiGuard.crisisReply(), false); // cloud ko call hi nahi
    }
    final c = await consent();
    final r = remote;
    if (c == AiConsent.off || r == null) {
      return (await offline.run(feature, payload, history: history), false);
    }
    try {
      final cloud = await r.run(feature, payload, history: history).timeout(remoteTimeout);
      final ids = <String>{
        for (final h in (payload['habits'] as List? ?? const [])) '${(h as Map)['id']}',
      };
      final safe = AiGuard.check(cloud.copyWith(fromCloud: true), knownHabitIds: ids);
      if (safe != null) return (safe, false);
    } catch (_) {
      // timeout / no internet / quota / backend down -> offline
    }
    return (await offline.run(feature, payload, history: history), true);
  }
}
