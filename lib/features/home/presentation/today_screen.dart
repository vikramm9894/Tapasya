import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/engines/score_engine.dart';
import '../../../domain/engines/xp_engine.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool isBareMin = false;
  int streakDays = 7;
  int dayNumber = 12;
  int totalDays = 90;

  // Mock list of daily items for Phase 0 demonstration
  final List<Map<String, dynamic>> _nonNegotiables = [
    {
      'id': '1',
      'title': 'Deep Study: Data Structures',
      'cue': 'Chai ke baad 1 ghanta',
      'difficulty': 3,
      'completed': true,
    },
    {
      'id': '2',
      'title': 'Morning 45-min Gym / Running',
      'cue': 'Uthte hi workout clothes pehno',
      'difficulty': 3,
      'completed': false,
    },
    {
      'id': '3',
      'title': 'Read 15 Pages of Book',
      'cue': 'Dinner ke baad bed par',
      'difficulty': 2,
      'completed': false,
    },
  ];

  final List<Map<String, dynamic>> _bonusHabits = [
    {
      'id': '4',
      'title': '10-min Mindfulness Meditation',
      'difficulty': 1,
      'completed': true,
    },
    {
      'id': '5',
      'title': 'Zero Sugar Today',
      'difficulty': 2,
      'completed': false,
    },
  ];

  bool checkedIn = false;

  int get calculatedScore {
    final nnDone = _nonNegotiables.where((h) => h['completed'] == true).length;
    final bonusDone = _bonusHabits.where((h) => h['completed'] == true).length;

    return ScoreEngine.calculate(
      nnDone: nnDone,
      nnTotal: _nonNegotiables.length,
      bonusDone: bonusDone,
      bonusTotal: _bonusHabits.length,
      checkedIn: checkedIn,
    );
  }

  void _toggleHabit(Map<String, dynamic> habit) {
    HapticFeedback.lightImpact();
    setState(() {
      habit['completed'] = !(habit['completed'] as bool);
    });

    if (habit['completed'] == true) {
      final xp = XpEngine.calculateHabitXp(
        habit['difficulty'] as int,
        isNonNeg: true,
        isBareMin: isBareMin,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.flash_on, color: AppTheme.secondaryEmber, size: 18),
              const SizedBox(width: 8),
              Text(
                '+$xp XP earned!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceElevated,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = calculatedScore;
    final todayStr = AppDateUtils.toDisplayString(AppDateUtils.todayKey());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TAPASYA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppTheme.primaryCyan.withOpacity(0.9),
              ),
            ),
            Text(
              todayStr,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$streakDays D',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Day Progress & Score Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.surfaceElevated,
                  AppTheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAY $dayNumber OF $totalDays',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBareMin ? 'Bare Minimum Mode' : 'Daily Mission',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isBareMin ? AppTheme.warningOrange : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Bare Min',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isBareMin,
                            activeColor: AppTheme.warningOrange,
                            onChanged: (val) {
                              setState(() => isBareMin = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Circular Score Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          score >= 70 ? AppTheme.primaryCyan : AppTheme.secondaryEmber,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3 Non-Negotiables Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield, color: AppTheme.primaryCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'NON-NEGOTIABLES (TOP 3)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${_nonNegotiables.where((h) => h['completed'] == true).length}/3',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Non-negotiable habit cards
          ..._nonNegotiables.map((habit) {
            final isDone = habit['completed'] as bool;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: isDone ? AppTheme.surfaceElevated.withOpacity(0.5) : AppTheme.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDone ? AppTheme.primaryCyan.withOpacity(0.4) : AppTheme.border,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  habit['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppTheme.textMuted : AppTheme.textPrimary,
                  ),
                ),
                subtitle: habit['cue'] != null
                    ? Text(
                        habit['cue'] as String,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? AppTheme.primaryCyan : AppTheme.textMuted,
                    size: 28,
                  ),
                  onPressed: () => _toggleHabit(habit),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Bonus Habits Header
          const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppTheme.secondaryEmber, size: 18),
              SizedBox(width: 8),
              Text(
                'BONUS HABITS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ..._bonusHabits.map((habit) {
            final isDone = habit['completed'] as bool;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(
                  habit['title'] as String,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppTheme.textMuted : AppTheme.textPrimary,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? AppTheme.secondaryEmber : AppTheme.textMuted,
                  ),
                  onPressed: () => _toggleHabit(habit),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Night Review Trigger Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: AppTheme.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(
              checkedIn ? Icons.lock : Icons.nightlight_round,
              color: AppTheme.secondaryEmber,
            ),
            label: Text(
              checkedIn ? 'Night Review Locked (Day Finalized)' : 'Complete Night Review (+10% Score)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            onPressed: () {
              setState(() {
                checkedIn = !checkedIn;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }
}
