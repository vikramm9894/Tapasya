import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/checkin_model.dart';
import '../../../domain/models/daily_log_model.dart';
import '../../home/providers/daily_log_provider.dart';

class NightReviewSheet extends ConsumerStatefulWidget {
  final int currentScoreWithoutCheckin;
  final VoidCallback onDayLocked;

  const NightReviewSheet({
    super.key,
    required this.currentScoreWithoutCheckin,
    required this.onDayLocked,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentScore,
    required VoidCallback onLocked,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: NightReviewSheet(
          currentScoreWithoutCheckin: currentScore,
          onDayLocked: onLocked,
        ),
      ),
    );
  }

  @override
  ConsumerState<NightReviewSheet> createState() => _NightReviewSheetState();
}

class _NightReviewSheetState extends ConsumerState<NightReviewSheet> {
  int _mood = 4;
  int _energy = 4;
  int _focus = 5;
  double _sleepHours = 7.5;

  final TextEditingController _winController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _tomorrowController = TextEditingController();

  @override
  void dispose() {
    _winController.dispose();
    _issueController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  Future<void> _lockDay() async {
    HapticFeedback.heavyImpact();
    final today = AppDateUtils.todayKey();

    final checkin = CheckinModel(
      date: today,
      mood: _mood,
      energy: _energy,
      focus: _focus,
      sleepHours: _sleepHours,
      win: _winController.text.trim().isEmpty ? null : _winController.text.trim(),
      issue: _issueController.text.trim().isEmpty ? null : _issueController.text.trim(),
      tomorrow: _tomorrowController.text.trim().isEmpty ? null : _tomorrowController.text.trim(),
    );

    // Save checkin
    await ref.read(dailyLogRepositoryProvider).saveCheckin(checkin);

    // Final score with +10% bonus
    final finalScore = (widget.currentScoreWithoutCheckin + 10).clamp(0, 100);
    final log = DailyLogModel(
      date: today,
      mode: 'normal',
      score: finalScore,
      xpEarned: 120,
    );
    await ref.read(dailyLogRepositoryProvider).saveDailyLog(log);

    widget.onDayLocked();
    if (mounted) Navigator.pop(context);
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
      child: SingleChildScrollView(
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
                const Row(
                  children: [
                    Icon(Icons.nightlight_round, color: AppTheme.secondaryEmber, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Evening Review & Lock-in',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryEmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+10% SCORE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryEmber),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Din khatam karne se pehle 30 second ka conscious reflection.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Rating Sliders
            _buildSlider('Mood', _mood, (v) => setState(() => _mood = v)),
            _buildSlider('Energy', _energy, (v) => setState(() => _energy = v)),
            _buildSlider('Deep Focus', _focus, (v) => setState(() => _focus = v)),

            // Sleep Slider with 6h min safety guardrail
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sleep Hours (Safety Min: 6h)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text('${_sleepHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
              ],
            ),
            Slider(
              value: _sleepHours,
              min: AppConstants.minSleepHours,
              max: AppConstants.maxSleepHours,
              divisions: 12,
              activeColor: AppTheme.primaryCyan,
              inactiveColor: AppTheme.border,
              onChanged: (val) => setState(() => _sleepHours = val),
            ),

            const SizedBox(height: 16),

            // 3-Line Reflection
            const Text('TODAY\'S WIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: _winController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. 1 ghanta DSA bina phone chhue kiya...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
              ),
            ),

            const SizedBox(height: 14),

            const Text('PLAN FOR TOMORROW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: _tomorrowController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Subah 7 baje gym jana hai...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.lock),
                label: const Text('Lock Day & Claim Bonus 🔥', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                onPressed: _lockDay,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text('$value/5', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppTheme.primaryCyan,
          inactiveColor: AppTheme.border,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
