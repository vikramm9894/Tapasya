import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/engines/adaptive_goal_engine.dart';

class AdaptiveGoalCard extends StatelessWidget {
  final AdaptiveGoalSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const AdaptiveGoalCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isIncrease = suggestion.changePercentage > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIncrease ? AppTheme.primaryCyan.withOpacity(0.4) : AppTheme.warningOrange.withOpacity(0.4),
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
                  Icon(
                    isIncrease ? Icons.trending_up : Icons.trending_down,
                    color: isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ADAPTIVE TARGET SUGGESTION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isIncrease ? '+25% TARGET' : '-25% TARGET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            suggestion.habitName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            suggestion.rationale,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          // Target Comparison Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Goal', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    Text('${suggestion.currentTarget.toInt()} min', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.arrow_forward, size: 18, color: AppTheme.textMuted),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Proposed Goal', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    Text(
                      '${suggestion.proposedTarget.toInt()} min',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismiss();
                },
                child: const Text('Keep Current', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIncrease ? AppTheme.primaryCyan : AppTheme.warningOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onAccept();
                },
                child: Text(
                  isIncrease ? 'Accept (+25%)' : 'Accept (-25%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
