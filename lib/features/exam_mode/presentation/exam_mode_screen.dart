import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/engines/exam_velocity_engine.dart';
import '../../../domain/models/exam_topic_model.dart';
import '../../../domain/models/subject_model.dart';

class ExamModeScreen extends StatefulWidget {
  const ExamModeScreen({super.key});

  @override
  State<ExamModeScreen> createState() => _ExamModeScreenState();
}

class _ExamModeScreenState extends State<ExamModeScreen> {
  final List<SubjectModel> _subjects = [
    SubjectModel(
      id: 'sub_1',
      name: 'Computer Science (GATE / Placement)',
      colorHex: '#00E5FF',
      examDate: DateTime.now().add(const Duration(days: 14)).toIso8601String().substring(0, 10),
    ),
    SubjectModel(
      id: 'sub_2',
      name: 'Higher Mathematics',
      colorHex: '#FFB300',
      examDate: DateTime.now().add(const Duration(days: 28)).toIso8601String().substring(0, 10),
    ),
  ];

  late String _selectedSubjectId;

  final List<ExamTopicModel> _topics = [
    const ExamTopicModel(id: 't1', subjectId: 'sub_1', title: 'Binary Trees, BFS & DFS Traversals', done: true, doneOn: '2026-10-01'),
    const ExamTopicModel(id: 't2', subjectId: 'sub_1', title: 'Dynamic Programming (Knapsack & LCS)', done: true, doneOn: '2026-10-01'),
    const ExamTopicModel(id: 't3', subjectId: 'sub_1', title: 'Graph Shortest Path & Dijkstra', done: false),
    const ExamTopicModel(id: 't4', subjectId: 'sub_1', title: 'B-Trees & Database B+ Indexing', done: false),
    const ExamTopicModel(id: 't5', subjectId: 'sub_1', title: 'Operating Systems: Semaphores & Deadlock', done: false),
    const ExamTopicModel(id: 't6', subjectId: 'sub_1', title: 'Computer Networks: TCP Congestion Control', done: false),
    const ExamTopicModel(id: 't7', subjectId: 'sub_2', title: 'Linear Algebra: Eigenvalues & SVD', done: true, doneOn: '2026-10-01'),
    const ExamTopicModel(id: 't8', subjectId: 'sub_2', title: 'Multivariate Calculus & Gradients', done: false),
    const ExamTopicModel(id: 't9', subjectId: 'sub_2', title: 'Probability & Bayesian Distributions', done: false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = _subjects.first.id;
  }

  SubjectModel get _currentSubject =>
      _subjects.firstWhere((s) => s.id == _selectedSubjectId, orElse: () => _subjects.first);

  List<ExamTopicModel> get _subjectTopics =>
      _topics.where((t) => t.subjectId == _selectedSubjectId).toList();

  void _toggleTopic(String topicId) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _topics.indexWhere((t) => t.id == topicId);
      if (index != -1) {
        final current = _topics[index];
        _topics[index] = current.copyWith(
          done: !current.done,
          doneOn: !current.done ? DateTime.now().toIso8601String().substring(0, 10) : null,
        );
      }
    });
  }

  void _showAddTopicDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Syllabus Topic', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Memory Management & Paging',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _topics.add(
                    ExamTopicModel(
                      id: 't_${DateTime.now().millisecondsSinceEpoch}',
                      subjectId: _selectedSubjectId,
                      title: text,
                      done: false,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Topic'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSubject = _currentSubject;
    final topics = _subjectTopics;
    final completedCount = topics.where((t) => t.done).length;
    final examDate = DateTime.tryParse(currentSubject.examDate ?? '') ??
        DateTime.now().add(const Duration(days: 14));

    final velocityResult = ExamVelocityEngine.calculate(
      totalTopics: topics.length,
      completedTopics: completedCount,
      examDate: examDate,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXAM MODE VELOCITY'),
        actions: [
          IconButton(
            tooltip: 'Add Topic',
            icon: const Icon(Icons.add_task, color: AppTheme.primaryCyan),
            onPressed: _showAddTopicDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Subject Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubjectId,
                dropdownColor: AppTheme.surfaceElevated,
                isExpanded: true,
                items: _subjects.map((sub) {
                  return DropdownMenuItem<String>(
                    value: sub.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(int.parse(sub.colorHex.replaceAll('#', '0xFF'))),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          sub.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSubjectId = val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Countdown & Velocity Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E28), Color(0xFF14141B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: velocityResult.status == VelocityStatus.critical
                    ? AppTheme.secondaryEmber
                    : AppTheme.primaryCyan.withOpacity(0.5),
              ),
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
                        const Text(
                          'TARGET COUNTDOWN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${velocityResult.daysRemaining} Days Left',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusPill(velocityResult.status),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: velocityResult.completionPercentage,
                    minHeight: 10,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      velocityResult.status == VelocityStatus.critical
                          ? AppTheme.secondaryEmber
                          : AppTheme.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedCount of ${topics.length} topics mastered (${(velocityResult.completionPercentage * 100).toInt()}%)',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '${velocityResult.requiredVelocity.toStringAsFixed(1)} / day required',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          velocityResult.statusMessage,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Launch Focus Session Action
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text(
              'Start 25m Focus Block for This Exam',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              context.go('/focus');
            },
          ),

          const SizedBox(height: 24),

          // Syllabus Topic Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYLLABUS CHECKLIST',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${velocityResult.remainingTopics} remaining',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (topics.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No syllabus topics added yet. Tap + to add topics.',
                  style: TextStyle(color: AppTheme.textMuted)),
            )
          else
            ...topics.map((topic) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: topic.done ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.border,
                  ),
                ),
                child: CheckboxListTile(
                  value: topic.done,
                  onChanged: (val) => _toggleTopic(topic.id),
                  activeColor: AppTheme.successGreen,
                  checkColor: Colors.black,
                  title: Text(
                    topic.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: topic.done ? TextDecoration.lineThrough : null,
                      color: topic.done ? AppTheme.textMuted : AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: topic.done && topic.doneOn != null
                    ? Text('Completed on ${topic.doneOn}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))
                    : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusPill(VelocityStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case VelocityStatus.completed:
        bg = AppTheme.successGreen.withOpacity(0.15);
        fg = AppTheme.successGreen;
        label = 'Completed';
        break;
      case VelocityStatus.comfortable:
        bg = AppTheme.primaryCyan.withOpacity(0.15);
        fg = AppTheme.primaryCyan;
        label = 'On Track';
        break;
      case VelocityStatus.moderate:
        bg = const Color(0xFFFFB300).withOpacity(0.15);
        fg = const Color(0xFFFFB300);
        label = 'Steady Focus';
        break;
      case VelocityStatus.critical:
        bg = AppTheme.secondaryEmber.withOpacity(0.15);
        fg = AppTheme.secondaryEmber;
        label = 'Accelerate';
        break;
      case VelocityStatus.overdue:
        bg = Colors.red.withOpacity(0.15);
        fg = Colors.redAccent;
        label = 'Exam Day';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
