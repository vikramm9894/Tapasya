enum VelocityStatus {
  completed,
  comfortable,
  moderate,
  critical,
  overdue,
}

class ExamVelocityResult {
  final int totalTopics;
  final int completedTopics;
  final int remainingTopics;
  final int daysRemaining;
  final double requiredVelocity; // Topics per day
  final double completionPercentage; // 0.0 to 1.0
  final VelocityStatus status;
  final String statusMessage;

  const ExamVelocityResult({
    required this.totalTopics,
    required this.completedTopics,
    required this.remainingTopics,
    required this.daysRemaining,
    required this.requiredVelocity,
    required this.completionPercentage,
    required this.status,
    required this.statusMessage,
  });
}

/// Pure Dart calculation engine for Exam Mode velocity and countdown metrics.
class ExamVelocityEngine {
  /// Calculates topic velocity and exam readiness without any UI or framework dependencies.
  static ExamVelocityResult calculate({
    required int totalTopics,
    required int completedTopics,
    required DateTime examDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    // Normalize dates to local midnight
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final examMidnight = DateTime(examDate.year, examDate.month, examDate.day);

    final daysRemaining = examMidnight.difference(todayMidnight).inDays;
    final clampedCompleted = completedTopics.clamp(0, totalTopics);
    final remainingTopics = totalTopics - clampedCompleted;
    final completionPercentage = totalTopics > 0 ? (clampedCompleted / totalTopics) : 1.0;

    if (totalTopics == 0 || remainingTopics == 0) {
      return ExamVelocityResult(
        totalTopics: totalTopics,
        completedTopics: clampedCompleted,
        remainingTopics: 0,
        daysRemaining: daysRemaining,
        requiredVelocity: 0.0,
        completionPercentage: 1.0,
        status: VelocityStatus.completed,
        statusMessage: 'Syllabus Completed! Revise & Conquer 🎉',
      );
    }

    if (daysRemaining <= 0) {
      return ExamVelocityResult(
        totalTopics: totalTopics,
        completedTopics: clampedCompleted,
        remainingTopics: remainingTopics,
        daysRemaining: daysRemaining,
        requiredVelocity: remainingTopics.toDouble(),
        completionPercentage: completionPercentage,
        status: VelocityStatus.overdue,
        statusMessage: 'Exam day has arrived! Give it your best shot ⚡',
      );
    }

    final velocity = remainingTopics / daysRemaining;

    VelocityStatus status;
    String message;

    if (velocity <= 1.0) {
      status = VelocityStatus.comfortable;
      message = 'On Track (${velocity.toStringAsFixed(1)} topics/day). Maintain rhythm!';
    } else if (velocity <= 2.5) {
      status = VelocityStatus.moderate;
      message = 'Steady Focus Required (${velocity.toStringAsFixed(1)} topics/day). Consistent daily study.';
    } else {
      status = VelocityStatus.critical;
      message = 'Acceleration Required! (${velocity.toStringAsFixed(1)} topics/day). Dedicate deep work blocks.';
    }

    return ExamVelocityResult(
      totalTopics: totalTopics,
      completedTopics: clampedCompleted,
      remainingTopics: remainingTopics,
      daysRemaining: daysRemaining,
      requiredVelocity: velocity,
      completionPercentage: completionPercentage,
      status: status,
      statusMessage: message,
    );
  }
}
