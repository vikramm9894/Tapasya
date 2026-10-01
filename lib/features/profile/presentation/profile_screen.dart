import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/engines/xp_engine.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const totalXp = 2450;
    final levelData = XpEngine.levelFor(totalXp);
    final progressToNext = levelData.into / levelData.need;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ME & PROGRESSION'),
        actions: [
          IconButton(
            tooltip: 'Settings & Privacy',
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Level Progression Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E28), Color(0xFF16161E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEVEL ${levelData.level}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          levelData.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.military_tech,
                      color: AppTheme.secondaryEmber,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressToNext,
                    minHeight: 10,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${levelData.into} XP earned',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '${levelData.need} XP to Level ${levelData.level + 1}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mini Challenges & Exam Velocity Action Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/challenges'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.secondaryEmber.withOpacity(0.5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⚔️ BOSS BATTLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryEmber)),
                        SizedBox(height: 4),
                        Text('Weekly Titan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('6 HP Left • Sprints', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/exam-mode'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎯 EXAM MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
                        SizedBox(height: 4),
                        Text('Velocity Tracker', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('14 Days • 1.4/day', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Season Recap Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.primaryCyan, width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.share, color: AppTheme.primaryCyan, size: 30),
              title: const Text(
                'Day 30 Season Recap Card',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Export your verified consistency snapshot for social sharing',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating Season Recap PNG snapshot...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Behavioral Achievements Header
          const Text(
            'UNLOCKED ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          _achievementTile(
            title: '7-Day Unbroken Streak',
            subtitle: 'Conquered the first week of Tapasya',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            unlocked: true,
          ),
          _achievementTile(
            title: 'Phoenix Recovery',
            subtitle: 'Overcame a miss with 2 consecutive success days',
            icon: Icons.refresh,
            color: AppTheme.primaryCyan,
            unlocked: true,
          ),
          _achievementTile(
            title: '50 Deep Focus Hours',
            subtitle: 'Dedicated 50 cumulative hours on study/work',
            icon: Icons.timer,
            color: AppTheme.secondaryEmber,
            unlocked: false,
          ),
        ],
      ),
    );
  }

  Widget _achievementTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool unlocked,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: unlocked ? color.withOpacity(0.15) : AppTheme.surfaceElevated,
          child: Icon(icon, color: unlocked ? color : AppTheme.textMuted),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Icon(
          unlocked ? Icons.check_circle : Icons.lock_outline,
          color: unlocked ? AppTheme.successGreen : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
