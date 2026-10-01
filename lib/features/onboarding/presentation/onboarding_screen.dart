import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/habit_model.dart';
import '../../../domain/models/journey_model.dart';
import '../../home/providers/habits_provider.dart';
import '../../home/providers/journey_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 2 inputs
  final TextEditingController _whyController = TextEditingController();
  final TextEditingController _letterController = TextEditingController();

  // Step 3 habit selection
  final List<HabitModel> _catalogHabits = [
    const HabitModel(
      id: 'h1',
      name: 'Deep Study / Coding (60m)',
      category: 'Study',
      kind: 'duration',
      targetValue: 60.0,
      minValue: 20.0,
      unit: 'min',
      difficulty: 3,
      cueText: 'Chai ke baad 1 ghanta desk par',
    ),
    const HabitModel(
      id: 'h2',
      name: 'Morning Workout / Run (45m)',
      category: 'Fitness',
      kind: 'duration',
      targetValue: 45.0,
      minValue: 15.0,
      unit: 'min',
      difficulty: 3,
      cueText: 'Uthte hi workout clothes pehno',
    ),
    const HabitModel(
      id: 'h3',
      name: 'Read 15 Pages of Book',
      category: 'Mindset',
      kind: 'count',
      targetValue: 15.0,
      minValue: 5.0,
      unit: 'pages',
      difficulty: 2,
      cueText: 'Dinner ke baad bed par',
    ),
    const HabitModel(
      id: 'h4',
      name: '10-min Mindfulness / Meditation',
      category: 'Health',
      kind: 'duration',
      targetValue: 10.0,
      minValue: 5.0,
      unit: 'min',
      difficulty: 1,
      cueText: 'Subah uthte hi 10 min silence',
    ),
    const HabitModel(
      id: 'h5',
      name: 'Zero Sugar & Healthy Diet',
      category: 'Health',
      kind: 'check',
      targetValue: 1.0,
      minValue: 1.0,
      difficulty: 2,
      cueText: 'Din bhar conscious discipline',
    ),
  ];

  late Set<String> _selectedHabitIds;
  int _selectedLength = 90;

  @override
  void initState() {
    super.initState();
    // Default select first 3 core habits
    _selectedHabitIds = {'h1', 'h2', 'h3'};
  }

  @override
  void dispose() {
    _pageController.dispose();
    _whyController.dispose();
    _letterController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.heavyImpact();
    const uuid = Uuid();
    final journeyId = uuid.v4();
    final today = AppDateUtils.todayKey();

    final journey = JourneyModel(
      id: journeyId,
      startDate: today,
      lengthDays: _selectedLength,
      whyText: _whyController.text.trim().isEmpty
          ? 'Khud ko disciplined aur focused banana hai.'
          : _whyController.text.trim(),
      letterText: _letterController.text.trim().isEmpty
          ? 'Day 90 tak bina ruke lage rehna.'
          : _letterController.text.trim(),
      status: 'active',
    );

    // Save journey
    await ref.read(journeyRepositoryProvider).createJourney(journey);

    // Save chosen habits
    final chosenHabits = _catalogHabits
        .where((h) => _selectedHabitIds.contains(h.id))
        .toList();
    await ref.read(habitRepositoryProvider).createInitialHabits(chosenHabits);

    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
                      onPressed: _prevPage,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isActive = index <= _currentStep;
                        return Container(
                          width: 32,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.primaryCyan : AppTheme.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (step) => setState(() => _currentStep = step),
                children: [
                  _buildStep1Welcome(),
                  _buildStep2WhyAndLetter(),
                  _buildStep3Habits(),
                  _buildStep4Commitment(),
                ],
              ),
            ),

            // Bottom Navigation CTA
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    _currentStep == 3 ? 'Start My Tapasya 🔥' : 'Continue',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Welcome & Philosophy
  Widget _buildStep1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceElevated,
              border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Text('ॐ', style: TextStyle(fontSize: 48, color: AppTheme.primaryCyan)),
          ),
          const SizedBox(height: 32),
          const Text(
            'TAPASYA',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Roz thoda. 90 din tak.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryEmber,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Winter Arc ek trend hai, Tapasya ek mission hai. 90 din ka deep, uninterrupted focus. No excuses, no fake grinding.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Why Statement & Day-90 Letter
  Widget _buildStep2WhyAndLetter() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'YOUR ANCHOR & LETTER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.primaryCyan,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kyun kar rahe ho ye?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Jab motivation kam padegi, ye "Why" statement aapko remind karayega.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _whyController,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Khud ko distract hone se rokna hai, exams clear karne hain...',
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryCyan),
            ),
          ),
        ),

        const SizedBox(height: 28),

        const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.secondaryEmber, size: 18),
            SizedBox(width: 8),
            Text(
              'Letter to Day 90 You (Locked)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Ek letter likho jo Day 90 par unlock hoga.',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _letterController,
          maxLines: 4,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Day 90 ke Vikram ko: Ummeed hai tumne haar nahi maani aur mission complete kiya...',
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondaryEmber),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Core Habit Picker (3-5 habits)
  Widget _buildStep3Habits() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'CHOOSE CORE HABITS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.primaryCyan,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '3 se 5 Non-Negotiables',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'In habits par roz kaam karna mandatory hoga streak bachane ke liye.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        ..._catalogHabits.map((habit) {
          final isSelected = _selectedHabitIds.contains(habit.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppTheme.surfaceElevated : AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryCyan : AppTheme.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              activeColor: AppTheme.primaryCyan,
              checkColor: Colors.black,
              title: Text(
                habit.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: habit.cueText != null
                  ? Text(
                      'Cue: ${habit.cueText}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    )
                  : null,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  if (val == true) {
                    _selectedHabitIds.add(habit.id);
                  } else {
                    if (_selectedHabitIds.length > 1) {
                      _selectedHabitIds.remove(habit.id);
                    }
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }

  // STEP 4: Journey Length & Start Date
  Widget _buildStep4Commitment() {
    final todayStr = AppDateUtils.toDisplayString(AppDateUtils.todayKey());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DURATION & START',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Apna Goal Choose Karo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),

          // Duration Selector
          Row(
            children: [30, 60, 90].map((days) {
              final isChosen = _selectedLength == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedLength = days);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isChosen ? AppTheme.surfaceElevated : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isChosen ? AppTheme.primaryCyan : AppTheme.border,
                        width: isChosen ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$days',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isChosen ? AppTheme.primaryCyan : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'DAYS',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.secondaryEmber, size: 20),
                    SizedBox(width: 10),
                    Text('Start Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(
                  todayStr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppTheme.successGreen, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Offline-First Guaranteed: Aapka koi bhi data kisi third-party server par nahi jayega.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
