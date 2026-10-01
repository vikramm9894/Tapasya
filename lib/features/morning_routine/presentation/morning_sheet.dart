import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../home/providers/daily_log_provider.dart';
import '../../home/providers/habits_provider.dart';

class MorningPrioritizationSheet extends ConsumerStatefulWidget {
  const MorningPrioritizationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MorningPrioritizationSheet(),
    );
  }

  @override
  ConsumerState<MorningPrioritizationSheet> createState() => _MorningPrioritizationSheetState();
}

class _MorningPrioritizationSheetState extends ConsumerState<MorningPrioritizationSheet> {
  final Set<String> _selectedHabitIds = {};

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final todayStr = AppDateUtils.toDisplayString(AppDateUtils.todayKey());

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
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MORNING ROUTINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pick Top 3 Non-Negotiables',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${_selectedHabitIds.length}/3',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'In 3 habits ko pura karne se aaj ka streak safe ho jayega ($todayStr).',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          // Habits List
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No active habits found. Create some first!')),
                );
              }

              return Column(
                children: habits.map((habit) {
                  final isSelected = _selectedHabitIds.contains(habit.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? AppTheme.surfaceElevated : AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryCyan : AppTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      activeColor: AppTheme.primaryCyan,
                      checkColor: Colors.black,
                      title: Text(habit.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: habit.cueText != null
                          ? Text('📌 ${habit.cueText}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))
                          : null,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (val == true) {
                            if (_selectedHabitIds.length < 3) {
                              _selectedHabitIds.add(habit.id);
                            }
                          } else {
                            _selectedHabitIds.remove(habit.id);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _selectedHabitIds.length == 3
                  ? () async {
                      HapticFeedback.heavyImpact();
                      final today = AppDateUtils.todayKey();
                      await ref
                          .read(dailyLogRepositoryProvider)
                          .setPrioritiesForDate(today, _selectedHabitIds.toList());
                      if (mounted) Navigator.pop(context);
                    }
                  : null,
              child: Text(
                _selectedHabitIds.length == 3 ? 'Lock Top 3 Priorities 🔥' : 'Select Exactly 3 (${_selectedHabitIds.length}/3)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
