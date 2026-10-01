import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/focus_provider.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  static const int defaultSessionSeconds = 25 * 60; // 25 minutes
  int _secondsRemaining = defaultSessionSeconds;
  Timer? _timer;
  bool _isRunning = false;
  String _selectedSubject = 'Computer Science';
  bool _isExamMode = true;

  final List<Map<String, dynamic>> _examTopics = [
    {'id': 't1', 'title': 'Binary Trees & BFS/DFS', 'done': true},
    {'id': 't2', 'title': 'Dynamic Programming Foundations', 'done': true},
    {'id': 't3', 'title': 'Graph Shortest Path (Dijkstra)', 'done': false},
    {'id': 't4', 'title': 'B-Trees & Database Indexing', 'done': false},
    {'id': 't5', 'title': 'Concurrency & Deadlock Resolution', 'done': false},
  ];

  int get _remainingTopics => _examTopics.where((t) => t['done'] == false).length;
  static const int _daysLeft = 14;
  double get _requiredVelocity => _daysLeft > 0 ? (_remainingTopics / _daysLeft) : 0.0;

  void _startPauseTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _onSessionCompleted();
        }
      });
      setState(() => _isRunning = true);
    }
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _secondsRemaining = defaultSessionSeconds;
      _isRunning = false;
    });
  }

  void _onSessionCompleted() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Tapasya Session Complete! 🔥'),
        content: Text(
          '25 minutes of deep focus on $_selectedSubject recorded. Auto-logged into your daily habits (+30 XP).',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress => 1.0 - (_secondsRemaining / defaultSessionSeconds);

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FOCUS & EXAM ENGINE'),
        actions: [
          IconButton(
            icon: Icon(
              _isExamMode ? Icons.school : Icons.school_outlined,
              color: _isExamMode ? AppTheme.secondaryEmber : AppTheme.textMuted,
            ),
            tooltip: 'Toggle Exam Mode',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isExamMode = !_isExamMode);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Subject Dropdown
          subjectsAsync.when(
            data: (subjects) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubject,
                    dropdownColor: AppTheme.surfaceElevated,
                    isExpanded: true,
                    items: subjects
                        .map((s) => DropdownMenuItem(
                              value: s.name,
                              child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 28),

          // Circular Pomodoro Display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 210,
                  height: 210,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 9,
                    backgroundColor: AppTheme.surfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _isRunning ? 'FOCUSING' : 'READY',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: _isRunning ? AppTheme.primaryCyan : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Timer Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                iconSize: 26,
                icon: const Icon(Icons.refresh),
                onPressed: _resetTimer,
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  backgroundColor: _isRunning ? AppTheme.warningOrange : AppTheme.primaryCyan,
                ),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(
                  _isRunning ? 'Pause' : 'Start Focus',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: _startPauseTimer,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Exam Mode Card
          if (_isExamMode) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.secondaryEmber.withOpacity(0.4)),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryEmber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'EXAM MODE ACTIVE',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondaryEmber),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Computer Science Final',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$_daysLeft',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.secondaryEmber),
                              ),
                              const Text('DAYS LEFT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Open Full Exam Mode Dashboard',
                            icon: const Icon(Icons.open_in_new, size: 20, color: AppTheme.primaryCyan),
                            onPressed: () => context.push('/exam-mode'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Velocity Banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pending Topics: $_remainingTopics', style: const TextStyle(fontSize: 12)),
                        Text(
                          'Velocity: ${_requiredVelocity.toStringAsFixed(1)} topic/day',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Topic Checklist
                  ..._examTopics.map((topic) {
                    final isDone = topic['done'] as bool;
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isDone,
                      activeColor: AppTheme.secondaryEmber,
                      checkColor: Colors.black,
                      title: Text(
                        topic['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AppTheme.textMuted : AppTheme.textPrimary,
                        ),
                      ),
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          topic['done'] = val ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
