import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DayDetailSheet extends StatelessWidget {
  final int dayNumber;
  final int score;
  final String status;
  final bool isToday;

  const DayDetailSheet({
    super.key,
    required this.dayNumber,
    required this.score,
    required this.status,
    this.isToday = false,
  });

  static Future<void> show(
    BuildContext context, {
    required int dayNumber,
    required int score,
    required String status,
    bool isToday = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DayDetailSheet(
        dayNumber: dayNumber,
        score: score,
        status: status,
        isToday: isToday,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY $dayNumber OF 90 ${isToday ? "• TODAY" : ""}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '$score/100',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: score >= 70 ? AppTheme.primaryCyan : AppTheme.secondaryEmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Habits Completed Summary
          const Text('HABITS LOGGED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),

          _logItem('Deep Study (60m)', 'Completed via Timer', true),
          _logItem('Morning Workout / Running', 'Completed 45m', true),
          _logItem('Read 15 Pages Book', 'Completed', dayNumber <= 11),

          const SizedBox(height: 16),

          // Evening Reflection Snapshot
          const Text('EVENING REFLECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sleep: 7.5h • Mood: 4/5 • Focus: 5/5', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Icon(Icons.verified, color: AppTheme.primaryCyan, size: 16),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '"Completed all DSA problem sets on trees without looking at solutions."',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logItem(String title, String sub, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppTheme.primaryCyan : AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, color: done ? AppTheme.textPrimary : AppTheme.textMuted)),
          const Spacer(),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
