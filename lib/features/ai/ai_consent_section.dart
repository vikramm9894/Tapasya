// lib/features/ai/ai_consent_section.dart
// Settings ke andar. Default: OFF. User ko exactly dikhao ki kya jata hai.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai/ai_models.dart';
import 'ai_providers.dart';

class AiConsentSection extends ConsumerWidget {
  const AiConsentSection({super.key});

  static const _opts = <(AiConsent, String, String)>[
    (AiConsent.off, 'Offline (default)',
        'Kuch bhi phone se bahar nahi jata. Rule-based coach chalta hai.'),
    (AiConsent.aggregates, 'AI - sirf numbers',
        'Score, habit completion %, sleep, mood/energy/focus (1-5) aur habit ke naam jate hain. Journal nahi.'),
    (AiConsent.aggregatesAndJournal, 'AI - numbers + journal',
        'Upar ka sab + Why text aur night-review ki 3 lines (email/phone hata kar). Day-90 letter kabhi nahi.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(aiConsentProvider).valueOrNull ?? AiConsent.off;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('AI Coach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        for (final o in _opts)
          ListTile(
            leading: Icon(o.$1 == current
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            title: Text(o.$2),
            subtitle: Text(o.$3),
            onTap: () => ref.read(aiConsentProvider.notifier).set(o.$1),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            children: [
              TextButton(
                onPressed: () async {
                  final json = await payloadPreview(ref);
                  if (!context.mounted) return;
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Cloud ko ye bheja jayega'),
                      content: SingleChildScrollView(
                        child: SelectableText(json,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context), child: const Text('Theek hai')),
                      ],
                    ),
                  );
                },
                child: const Text('Kya bheja jata hai? (preview)'),
              ),
              TextButton(
                onPressed: () => ref.read(chatControllerProvider.notifier).clear(),
                child: const Text('Chat history delete karo'),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'AI opt-in par internet chahiye. Net na ho ya cloud fail ho to app apne aap offline coach par aa jata hai.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
