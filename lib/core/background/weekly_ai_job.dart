// lib/core/background/weekly_ai_job.dart
// Tumhara existing Sunday 8 PM WorkManager job is function ko notification se PEHLE call kare.
// Naya notification add nahi hota -> 3/din limit safe.
import '../../domain/ai/ai_context_builder.dart';
import '../../domain/ai/ai_models.dart';
import '../../domain/ai/ai_service.dart';

/// Hamesha complete hota hai (max ~25s). Fail ho to bhi notification chalni chahiye.
Future<void> precomputeWeeklyAi({
  required AiService service,
  required AiPayloadFactory factory,
  required Future<AiConsent> Function() consent,
}) async {
  try {
    final c = await consent();
    final now = DateTime.now();
    for (final (f, key) in [
      (AiFeature.weeklyCoach, AiKeys.weekly(now)),
      (AiFeature.goalSuggestions, AiKeys.goals(now)),
    ]) {
      final payload = await factory.build(f, c);
      await service.run(f, payload, cacheKey: key).timeout(const Duration(seconds: 25));
    }
  } catch (_) {
    // ignore: notification phir bhi jayegi; UI khulne par insight on-demand ban jayega
  }
}

/* callbackDispatcher mein (background isolate) pehle ye zaroor karo:

   WidgetsFlutterBinding.ensureInitialized();
   DartPluginRegistrant.ensureInitialized();
   // phir apna DB open karo, settings repo, AiService banao (providers yahan nahi chalte).
   // Firebase.initializeApp() RemoteAiProvider khud lazily kar leta hai.
*/
