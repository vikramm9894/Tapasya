// lib/data/ai/remote_ai_provider.dart
// Cloud AI: Firebase callable function -> backend -> Claude API. API key app mein NAHI hai.
// Firebase tabhi initialize hota hai jab user AI opt-in karke pehli baar cloud call kare.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/ai/ai_models.dart';
import '../../domain/ai/ai_provider.dart';

class RemoteAiProvider implements AiProvider {
  RemoteAiProvider({this.region = 'asia-south1'});
  final String region;

  Future<void> _ensureReady() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    // App Check (Play Integrity) yahan activate karo. Parameter naam firebase_app_check
    // ke version ke hisaab se badalte hain - package ka changelog dekho.
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) await auth.signInAnonymously(); // per-install quota ke liye
  }

  @override
  Future<AiResult> run(
    AiFeature feature,
    Map<String, dynamic> payload, {
    List<ChatTurn> history = const [],
  }) async {
    try {
      await _ensureReady();
      final callable = FirebaseFunctions.instanceFor(region: region).httpsCallable(
        'tapasyaAi',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      final h = history.length > 10 ? history.sublist(history.length - 10) : history;
      final res = await callable.call({
        'feature': feature.name,
        'payload': payload,
        'history': [for (final t in h) t.toJson()],
      });
      return AiResult.fromJson(Map<String, dynamic>.from(res.data as Map), fromCloud: true);
    } on FirebaseFunctionsException catch (e) {
      throw AiException('${e.code}: ${e.message}');
    }
  }
}
