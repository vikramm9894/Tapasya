// lib/features/ai/ai_chat_screen.dart
// Route: /coach  (Me tab ya Weekly Review se). "Mera Why" local DB se dikhta hai, AI ke through nahi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart'; // aiDataSourceProvider
import '../../domain/ai/ai_models.dart';
import 'ai_providers.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;

  Future<void> _send() async {
    final t = _ctrl.text;
    if (t.trim().isEmpty || _busy) return;
    _ctrl.clear();
    setState(() => _busy = true);
    try {
      await ref.read(chatControllerProvider.notifier).send(t);
    } finally {
      if (mounted) setState(() => _busy = false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  Future<void> _showWhy() async {
    final why = await ref.read(aiDataSourceProvider).whyText();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tumhara Why'),
        content: Text(why?.isNotEmpty == true ? why! : 'Abhi koi Why save nahi hai.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final consent = ref.watch(aiConsentProvider).valueOrNull ?? AiConsent.off;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        actions: [IconButton(icon: const Icon(Icons.favorite_border), tooltip: 'Mera Why', onPressed: _showWhy)],
      ),
      body: Column(
        children: [
          if (consent == AiConsent.off)
            const MaterialBanner(
              content: Text('Offline mode: jawab limited hain. Settings > AI Coach se opt-in karo.'),
              actions: [SizedBox.shrink()],
            ),
          Expanded(
            child: chat.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Chat load nahi hui.')),
              data: (turns) => ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: turns.length,
                itemBuilder: (_, i) {
                  final t = turns[i];
                  final me = t.role == 'user';
                  return Align(
                    alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: me
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(t.content),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(hintText: 'Kuch bhi bolo...', counterText: ''),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _busy ? null : _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
