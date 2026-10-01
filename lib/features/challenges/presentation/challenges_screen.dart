import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/challenge_model.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  // Weekly Boss
  int _bossHp = 6;
  final int _bossMaxHp = 15;
  bool _bossDefeated = false;

  final List<ChallengeModel> _challenges = [
    const ChallengeModel(
      id: 'c_7d',
      title: '7-Day Discipline Sprint',
      subtitle: 'Complete all Top 3 Non-Negotiables for 7 consecutive days',
      kind: '7d',
      targetCount: 7,
      currentCount: 5,
      xpReward: 200,
      badgeKey: 'sprint_7d',
    ),
    const ChallengeModel(
      id: 'c_focus_weekend',
      title: 'Deep Work Weekend Arc',
      subtitle: 'Accumulate 4 deep focus Pomodoro sessions on study/skills',
      kind: 'custom',
      targetCount: 4,
      currentCount: 4,
      xpReward: 120,
      badgeKey: 'weekend_warrior',
    ),
    const ChallengeModel(
      id: 'c_30d',
      title: '30-Day Monk Arc',
      subtitle: 'Achieve 30 consecutive days of Tapasya without broken streak',
      kind: '30d',
      targetCount: 30,
      currentCount: 12,
      xpReward: 500,
      badgeKey: 'monk_30d',
    ),
  ];

  void _claimChallenge(int index) {
    HapticFeedback.heavyImpact();
    setState(() {
      _challenges[index] = _challenges[index].copyWith(isCompleted: true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Claimed +${_challenges[index].xpReward} XP! Badge Unlocked!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _attackBoss() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_bossHp > 1) {
        _bossHp -= 1;
      } else {
        _bossHp = 0;
        _bossDefeated = true;
      }
    });

    if (_bossDefeated) {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('⚔️ BOSS DEFEATED! ⚔️', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text(
            'You conquered the Procrastination Titan with your weekly consistency!\n\nAwarded: +150 XP & "Titan Slayer" Badge.',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Claim Victory'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bossProgress = 1.0 - (_bossHp / _bossMaxHp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHALLENGES & BOSS BATTLES'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weekly Boss Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1520), Color(0xFF16161E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _bossDefeated ? AppTheme.successGreen : AppTheme.secondaryEmber.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _bossDefeated ? '🏆' : '👹',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WEEKLY BOSS BATTLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: AppTheme.secondaryEmber,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _bossDefeated ? 'Titan Vanquished!' : 'Procrastination Titan',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _bossDefeated ? 'VICTORY' : '$_bossHp / $_bossMaxHp HP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _bossDefeated ? AppTheme.successGreen : AppTheme.secondaryEmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: bossProgress,
                    minHeight: 12,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _bossDefeated ? AppTheme.successGreen : AppTheme.secondaryEmber,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Deal 1 HP damage for every habit completed this week. Defeat the Titan before Sunday midnight!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                if (!_bossDefeated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryEmber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.flash_on, size: 20),
                      label: const Text('Sync Weekly Habit Hits (Attack Boss)'),
                      onPressed: _attackBoss,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active Sprints Header
          const Text(
            'ACTIVE CONSISTENCY SPRINTS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          ..._challenges.asMap().entries.map((entry) {
            final idx = entry.key;
            final challenge = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: challenge.isCompleted
                      ? AppTheme.successGreen.withOpacity(0.4)
                      : challenge.canClaim
                          ? AppTheme.primaryCyan
                          : AppTheme.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            challenge.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${challenge.xpReward} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challenge.subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: challenge.progressRatio,
                        minHeight: 8,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          challenge.isCompleted ? AppTheme.successGreen : AppTheme.primaryCyan,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${challenge.currentCount} / ${challenge.targetCount} days completed',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        if (challenge.isCompleted)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: AppTheme.successGreen),
                              SizedBox(width: 4),
                              Text('Claimed', style: TextStyle(fontSize: 12, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                            ],
                          )
                        else if (challenge.canClaim)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _claimChallenge(idx),
                            child: const Text('Claim Reward', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          Text(
                            '${((1.0 - challenge.progressRatio) * challenge.targetCount).toInt()} left',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
