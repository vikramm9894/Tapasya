// lib/domain/ai/ai_provider.dart
import 'ai_models.dart';

/// Offline aur cloud, dono yahi interface implement karte hain.
/// chat ke liye: history ka aakhri element user ka naya message hota hai.
abstract class AiProvider {
  Future<AiResult> run(
    AiFeature feature,
    Map<String, dynamic> payload, {
    List<ChatTurn> history = const [],
  });
}
