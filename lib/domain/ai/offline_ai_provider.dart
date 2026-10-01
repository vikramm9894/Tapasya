// lib/domain/ai/offline_ai_provider.dart
// Rule-based "AI": internet nahi ho, consent off ho, ya cloud fail ho - tab yahi chalta hai.
import 'ai_models.dart';
import 'ai_provider.dart';

class OfflineAiProvider implements AiProvider {
  const OfflineAiProvider();

  @override
  Future<AiResult> run(
    AiFeature feature,
    Map<String, dynamic> payload, {
    List<ChatTurn> history = const [],
  }) async {
    switch (feature) {
      case AiFeature.weeklyCoach:
        return _weekly(payload);
      case AiFeature.nightInsight:
        return _night(payload);
      case AiFeature.goalSuggestions:
        return _goals(payload);
      case AiFeature.chat:
        return _chat(payload, history);
    }
  }

  // ---------- helpers ----------
  List<Map<String, dynamic>> _list(Object? v) => [
        for (final e in (v as List? ?? const [])) Map<String, dynamic>.from(e as Map),
      ];

  double _avg(Iterable<num> xs) =>
      xs.isEmpty ? 0 : xs.fold<double>(0, (a, b) => a + b) / xs.length;

  int _pct(Object? v) => (((v as num?) ?? 0) * 100).round();

  String? _sleepFocus(List<Map<String, dynamic>> days) {
    final good = [
      for (final d in days)
        if (d['sleep'] != null && d['focus'] != null && (d['sleep'] as num) >= 7) d['focus'] as num
    ];
    final bad = [
      for (final d in days)
        if (d['sleep'] != null && d['focus'] != null && (d['sleep'] as num) < 7) d['focus'] as num
    ];
    if (good.length < 4 || bad.length < 4) return null; // data kam hai
    final diff = _avg(good) - _avg(bad);
    if (diff < 0.4) return null;
    final pct = (diff / _avg(bad) * 100).round();
    return 'Jin dino sleep 7+ ghante thi, focus ~$pct% zyada raha.';
  }

  // ---------- weekly coach ----------
  AiResult _weekly(Map<String, dynamic> p) {
    final days = _list(p['days']);
    if (days.isEmpty) {
      return const AiResult(
        text: 'Abhi data kam hai. Kuch din log karo, phir weekly review ban jayega.',
      );
    }
    final last7 = days.length > 7 ? days.sublist(days.length - 7) : days;
    final habits = _list(p['habits']);
    final j = Map<String, dynamic>.from(p['journey'] as Map);
    final avgScore = _avg(last7.map((d) => d['score'] as num)).round();
    final lines = <String>[
      'Is hafte ka average score $avgScore/100 raha (Day ${j['day']}/${j['length']}).',
    ];
    if (habits.isNotEmpty) {
      final s = [...habits]..sort((a, b) => (b['rate7'] as num).compareTo(a['rate7'] as num));
      final best = s.first, worst = s.last;
      lines.add('Sabse strong: ${best['name']} (${_pct(best['rate7'])}%).');
      if (worst['id'] != best['id']) {
        final wd = worst['worstWeekday'];
        lines.add('Sabse zyada miss: ${worst['name']} (${_pct(worst['rate7'])}%)'
            '${wd != null ? ', khaaskar $wd ko' : ''}.');
      }
    }
    final sf = _sleepFocus(days);
    if (sf != null) lines.add(sf);
    if (avgScore >= 80) {
      lines.add('Agle hafte yehi rhythm rakho. Chaho to ek habit ka target thoda badhao.');
    } else if (avgScore >= 60) {
      lines.add('Agle hafte sabse weak habit ko ek fixed cue-time par rakho.');
    } else {
      lines.add('Agle hafte Bare Minimum ko dost banao - chhota version bhi streak bachata hai.');
    }
    return AiResult(text: lines.join('\n'));
  }

  // ---------- night insight ----------
  AiResult _night(Map<String, dynamic> p) {
    final days = _list(p['days']);
    if (days.isEmpty) return const AiResult(text: 'Din complete! Kal ke liye ek chhota target socho.');
    final t = days.last;
    final score = (t['score'] as num).toInt();
    final lines = <String>[];
    if (t['mode'] == 'bare_min') {
      lines.add('Bad day par bhi Bare Minimum kiya - yahi asli consistency hai.');
    } else if (t['mode'] == 'rest') {
      lines.add('Rest day bhi plan ka hissa hai. Kal fresh shuru karo.');
    } else if (score >= 85) {
      lines.add('Zabardast din: $score/100.');
    } else if (score >= 70) {
      lines.add('Solid din: $score/100. Streak safe hai.');
    } else {
      lines.add('Aaj $score/100 raha. Ek kamzor din se kuch nahi bigadta.');
    }
    final energy = t['energy'] as num?;
    final sleep = t['sleep'] as num?;
    if (energy != null && energy <= 2) {
      lines.add('Energy kam thi - kal subah ka pehla task halka rakho.');
    } else if (sleep != null && sleep < 7) {
      lines.add('Sleep ${sleep.toStringAsFixed(1)} ghante thi. Aaj thoda jaldi so jao.');
    }
    lines.add('Kal ka sabse chhota pehla kadam kya hoga?');
    return AiResult(text: lines.join('\n'));
  }

  // ---------- goal suggestions (adaptive rule: 14-din) ----------
  AiResult _goals(Map<String, dynamic> p) {
    final s = <AiSuggestion>[];
    for (final h in _list(p['habits'])) {
      final r = (h['rate14'] as num).toDouble();
      if (r >= 0.85) {
        s.add(AiSuggestion(
          habitId: '${h['id']}',
          kind: 'increase',
          changePct: 0.25,
          reason: '${h['name']}: 14 din mein ${_pct(r)}% completion. Target +25% try kar sakte ho.',
        ));
      } else if (r < 0.50) {
        s.add(AiSuggestion(
          habitId: '${h['id']}',
          kind: 'decrease',
          changePct: 0.25,
          reason: '${h['name']}: 14 din mein ${_pct(r)}% hi hua. Target -25% karke dobara pakdo.',
        ));
      }
      if (s.length == 3) break;
    }
    return AiResult(
      text: s.isEmpty
          ? 'Abhi saare targets sahi chal rahe hain. Koi badlav suggest nahi.'
          : 'Ye sirf suggestions hain - accept karna ya nahi, tumhara faisla.',
      suggestions: s,
    );
  }

  // ---------- chat (limited, rule-based) ----------
  bool _has(String m, List<String> keys) => keys.any(m.contains);

  AiResult _chat(Map<String, dynamic> p, List<ChatTurn> history) {
    final m = history.isEmpty ? '' : history.last.content.toLowerCase();
    final j = Map<String, dynamic>.from((p['journey'] as Map?) ?? const {});
    final streak = j['streak'] ?? 0;
    final why = p['why'] as String?;
    if (_has(m, ['thak', 'tired', 'mann nahi', 'bore', 'demotiv', 'nahi ho raha', 'give up', 'chhod'])) {
      final whyLine = why != null ? ' Yaad karo tumne kyun shuru kiya tha: "$why".' : '';
      return AiResult(
        text: 'Samajh sakta hoon. Aaj poora score zaroori nahi - sirf Bare Minimum karo, '
            'streak bachi rahegi.$whyLine',
      );
    }
    if (_has(m, ['miss', 'toot', 'chhut', 'streak'])) {
      return AiResult(
        text: 'Streak ab $streak din ki hai. Ek miss se sab khatam nahi hota - '
            'freeze aur Phoenix Recovery isi liye hain. Aaj 10 minute ka Recovery Day karo.',
      );
    }
    if (_has(m, ['plan', 'kya karu', 'kaise', 'help'])) {
      return const AiResult(
        text: 'Simple rakho: aaj ke 3 non-negotiables chuno, pehla sabse aasaan wala abhi shuru karo, '
            'baaki baad mein.',
      );
    }
    return const AiResult(
      text: 'Main yahan hoon. Offline mode mein mere jawab limited hain - Settings mein AI opt-in '
          'karoge to behtar personalised coaching milegi. Abhi bolo, aaj sabse bada atkaav kya hai?',
    );
  }
}
