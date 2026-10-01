import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/habit_model.dart';
import '../../home/providers/habits_provider.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cueController = TextEditingController();
  final _targetController = TextEditingController(text: '30');
  final _minController = TextEditingController(text: '10');
  final _unitController = TextEditingController(text: 'min');

  String _category = 'Study';
  String _kind = 'duration';
  int _difficulty = 2; // 1: easy, 2: medium, 3: hard
  TimeOfDay? _cueTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _cueController.dispose();
    _targetController.dispose();
    _minController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    const uuid = Uuid();
    final targetVal = double.tryParse(_targetController.text.trim()) ?? 1.0;
    final minVal = double.tryParse(_minController.text.trim()) ?? 1.0;

    final habit = HabitModel(
      id: uuid.v4(),
      name: _nameController.text.trim(),
      category: _category,
      kind: _kind,
      targetValue: targetVal,
      minValue: minVal,
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      difficulty: _difficulty,
      cueText: _cueController.text.trim().isEmpty ? null : _cueController.text.trim(),
      cueTime: _cueTime != null ? '${_cueTime!.hour}:${_cueTime!.minute.toString().padLeft(2, '0')}' : null,
      isActive: true,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );

    ref.read(habitRepositoryProvider).createHabit(habit);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habit "${habit.name}" created! 🔥'),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW HABIT'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Habit Name
            const Text('HABIT NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Operating Systems Revision',
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Habit name is required' : null,
            ),

            const SizedBox(height: 20),

            // Category Selector
            const Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.habitCategories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryCyan.withOpacity(0.2),
                  backgroundColor: AppTheme.surfaceElevated,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryCyan : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) => setState(() => _category = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Habit Stacking Cue (If-Then)
            const Row(
              children: [
                Icon(Icons.link, color: AppTheme.primaryCyan, size: 18),
                SizedBox(width: 6),
                Text('IF-THEN CUE (HABIT STACKING)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Research shows specific cues work 2x better than vague intentions.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cueController,
              decoration: InputDecoration(
                hintText: 'e.g. Chai ke baad 20 min padhna...',
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              ),
            ),

            const SizedBox(height: 20),

            // Targets: Standard vs Bare Minimum
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TARGET GOAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceElevated,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BARE MINIMUM (BAD DAYS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.warningOrange)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceElevated,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.warningOrange)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Difficulty & XP Tier
            const Text('DIFFICULTY (XP TIER)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _difficultyCard(1, 'Easy', '10 XP'),
                const SizedBox(width: 10),
                _difficultyCard(2, 'Medium', '20 XP'),
                const SizedBox(width: 10),
                _difficultyCard(3, 'Hard', '30 XP'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyCard(int level, String label, String xp) {
    final isSelected = _difficulty == level;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _difficulty = level);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceElevated : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.secondaryEmber : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.secondaryEmber : AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(xp, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
