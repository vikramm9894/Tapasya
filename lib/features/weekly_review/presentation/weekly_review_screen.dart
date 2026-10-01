import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/engines/adaptive_goal_engine.dart';
import 'widgets/adaptive_goal_card.dart';

class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  bool _goalAccepted = false;
  bool _goalDismissed = false;

  final AdaptiveGoalSuggestion _mockSuggestion = const AdaptiveGoalSuggestion(
    habitId: 'h1',
    habitName: 'Deep Study / Coding',
    currentTarget: 60.0,
    proposedTarget: 75.0,
    changePercentage: 0.25,
    rationale: 'Pichhle 14 din mein 90% consistency! Target badhane ka best time hai.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNDAY WEEKLY REVIEW'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Weekly Score Ring Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1C2B), Color(0xFF13131A)],
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
                    const Text(
                      'WEEK 2 COMPLETED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.secondaryEmber,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Weekly Discipline',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6 of 7 Days Completed (86%)',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryCyan, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withOpacity(0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '86%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Best vs Most Missed Habit Highlights
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.secondaryEmber, size: 16),
                          SizedBox(width: 4),
                          Text('BEST HABIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Deep Study', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('7/7 Days (100%)', style: TextStyle(fontSize: 11, color: AppTheme.successGreen)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 16),
                          SizedBox(width: 4),
                          Text('MOST MISSED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Read 15 Pages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('Missed on Saturday', style: TextStyle(fontSize: 11, color: AppTheme.warningOrange)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Offline Rule-Based Insights Section
          const Text(
            'ON-DEVICE CORRELATION INSIGHTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          _insightCard(
            icon: Icons.bedtime,
            iconColor: Colors.indigoAccent,
            title: 'Sleep vs. Focus Correlation',
            body: 'Jin dino sleep 7+ ghante thi, deep focus score ~33% zyada raha.',
          ),

          const SizedBox(height: 10),

          _insightCard(
            icon: Icons.calendar_view_week,
            iconColor: AppTheme.warningOrange,
            title: 'Weekend Drop-off Detected',
            body: 'Weekends par consistency ~25% gir jati hai. Saturday aur Sunday ke liye Morning Sheet subah hi lock karo.',
          ),

          const SizedBox(height: 24),

          // Adaptive Goal Suggestion Card
          if (!_goalAccepted && !_goalDismissed) ...[
            AdaptiveGoalCard(
              suggestion: _mockSuggestion,
              onAccept: () {
                setState(() => _goalAccepted = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Target updated to 75 min! Tapasya level up! 🔥'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onDismiss: () {
                setState(() => _goalDismissed = true);
              },
            ),
            const SizedBox(height: 24),
          ],

          // Next Week Plan Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start Week 3 Tapasya 🔥', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
