// lib/domain/ai/ai_guard.dart
// Cloud AI ka jawab app mein dikhne se pehle yahan se guzarta hai.
import 'ai_models.dart';

class AiGuard {
  static const double minSleepHours = 6.0; // strict rule #5
  static const double maxChange = 0.25; // adaptive goal limit
  static const int maxChars = 1200;
  static const int maxSuggestions = 3;

  // "sleep 4 ghante" / "4 hours of sleep" jaise sujhav pakadta hai.
  static final _sleepA = RegExp(
    r'(sleep|neend|sona)[^.\n]{0,25}?\b([0-5](?:\.\d+)?)\s*(?:hours?|hrs?|ghant[ea])',
    caseSensitive: false,
  );
  static final _sleepB = RegExp(
    r'\b([0-5](?:\.\d+)?)\s*(?:hours?|hrs?|ghant[ea])[^.\n]{0,15}?(?:sleep|neend|sona)',
    caseSensitive: false,
  );
  static final _extreme = RegExp(
    r'(crash diet|starv|bhookhe rah|skip (?:all )?meals|water fast|dry fast|\b\d{3,4}\s*kcal)',
    caseSensitive: false,
  );

  static final _crisis = RegExp(
    r'(suicide|suicidal|khudkushi|kill myself|end my life|marna chahta|marna chahti|'
    r'mar jaun|mar jana chahta|jeena nahi|jina nahi|jeene ka mann nahi|khatam kar lu|'
    r'self[- ]?harm|apne aap ko hurt)',
    caseSensitive: false,
  );

  static bool _bad(String s) =>
      _sleepA.hasMatch(s) || _sleepB.hasMatch(s) || _extreme.hasMatch(s);

  /// Keyword-based pehli line of defence. Perfect nahi hai; cloud prompt mein bhi
  /// crisis rule hai.
  static bool isCrisis(String message) => _crisis.hasMatch(message);

  static AiResult crisisReply() => const AiResult(
        text: 'Tumne jo likha woh bahut bhaari hai, aur main use halke mein nahi le raha. '
            'Please abhi kisi bharosemand insaan se baat karo - ghar ka koi, dost, ya '
            'koi bhi jo paas ho. Tele-MANAS (14416) 24x7 free helpline hai. '
            'Agar turant khatra lag raha ho to 112 par call karo. '
            'Tapasya ka streak ya score is waqt zaroori nahi hai - tum zaroori ho.',
      );

  /// null = reject. AiService tab offline provider par fallback karta hai.
  static AiResult? check(AiResult r, {Set<String>? knownHabitIds}) {
    final text = r.text.trim();
    if (text.isEmpty || _bad(text)) return null;
    final safeText = text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;

    final out = <AiSuggestion>[];
    for (final s in r.suggestions) {
      if (out.length >= maxSuggestions) break;
      if (knownHabitIds != null && !knownHabitIds.contains(s.habitId)) continue;
      if (!const {'increase', 'decrease', 'keep'}.contains(s.kind)) continue;
      if (_bad(s.reason)) return null;
      final pct = s.kind == 'keep' ? 0.0 : s.changePct.clamp(0.0, maxChange).toDouble();
      final reason = s.reason.length > 200 ? s.reason.substring(0, 200) : s.reason;
      out.add(AiSuggestion(habitId: s.habitId, kind: s.kind, changePct: pct, reason: reason));
    }
    return r.copyWith(text: safeText, suggestions: out);
  }
}
