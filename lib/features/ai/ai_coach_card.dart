// lib/features/ai/ai_coach_card.dart
// Weekly Review screen + Night review sheet + suggestions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart'; // <- AiSuggestionRow yahan se aata hai
import '../../domain/ai/ai_models.dart';
import 'ai_providers.dart';

class _Badge extends StatelessWidget {
  const _Badge(this.cloud);
  final bool cloud;
  @override
  Widget build(BuildContext context) => Text(
        cloud ? 'AI (cloud)' : 'Offline coach',
        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary),
      );
}

class AiCoachCard extends ConsumerWidget {
  const AiCoachCard({super.key, this.feature = AiFeature.weeklyCoach});
  final AiFeature feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = feature == AiFeature.nightInsight
        ? ref.watch(aiNightProvider)
        : ref.watch(aiWeeklyProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: async.when(
          loading: () => const SizedBox(height: 56, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => const Text('Insight abhi nahi ban paya. Baad mein try karo.'),
          data: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Badge(r.fromCloud),
                  IconButton(
                    tooltip: 'Dobara banao',
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: () => regenerate(ref, feature),
                  ),
                ],
              ),
              Text(r.text),
            ],
          ),
        ),
      ),
    );
  }
}

/// Adaptive goal suggestions. Auto-change KABHI nahi: user Accept/Dismiss karta hai.
class AiSuggestionCards extends ConsumerWidget {
  const AiSuggestionCards({super.key, required this.onAccept});

  /// Tumhare HabitRepo ko call karo: target_value ko factor se scale karo.
  /// factor = 1.25 (increase) ya 0.75 (decrease). min_value ko target se upar mat jaane do.
  final Future<void> Function(String habitId, double factor) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(aiGoalsProvider); // generate + save trigger
    final repo = ref.watch(aiRepoProvider);
    return StreamBuilder<List<AiSuggestionRow>>(
      stream: repo.pending(mondayIso(DateTime.now())),
      builder: (context, snap) {
        final items = snap.data ?? const <AiSuggestionRow>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final s in items)
              Card(
                child: ListTile(
                  title: Text(s.reason),
                  subtitle: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final f = s.kind == 'increase' ? 1 + s.changePct : 1 - s.changePct;
                          await onAccept(s.habitId, f);
                          await repo.setStatus(s.id, 'accepted');
                        },
                        child: const Text('Accept'),
                      ),
                      TextButton(
                        onPressed: () => repo.setStatus(s.id, 'dismissed'),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
