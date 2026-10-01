import 'package:flutter_test/flutter_test.dart';
import 'package:tapasya/domain/engines/exam_velocity_engine.dart';

void main() {
  group('ExamVelocityEngine Tests', () {
    final fixedToday = DateTime(2026, 10, 1);

    test('calculates comfortable pace when topics <= days remaining', () {
      final examDate = DateTime(2026, 10, 15); // 14 days remaining
      final result = ExamVelocityEngine.calculate(
        totalTopics: 10,
        completedTopics: 3,
        examDate: examDate,
        currentDate: fixedToday,
      );

      expect(result.daysRemaining, 14);
      expect(result.remainingTopics, 7);
      expect(result.requiredVelocity, closeTo(0.5, 0.01));
      expect(result.status, VelocityStatus.comfortable);
      expect(result.completionPercentage, 0.3);
    });

    test('calculates moderate pace when velocity between 1.0 and 2.5', () {
      final examDate = DateTime(2026, 10, 11); // 10 days remaining
      final result = ExamVelocityEngine.calculate(
        totalTopics: 20,
        completedTopics: 0,
        examDate: examDate,
        currentDate: fixedToday,
      );

      expect(result.daysRemaining, 10);
      expect(result.remainingTopics, 20);
      expect(result.requiredVelocity, 2.0);
      expect(result.status, VelocityStatus.moderate);
    });

    test('calculates critical pace when velocity > 2.5', () {
      final examDate = DateTime(2026, 10, 6); // 5 days remaining
      final result = ExamVelocityEngine.calculate(
        totalTopics: 25,
        completedTopics: 5,
        examDate: examDate,
        currentDate: fixedToday,
      );

      expect(result.daysRemaining, 5);
      expect(result.remainingTopics, 20);
      expect(result.requiredVelocity, 4.0);
      expect(result.status, VelocityStatus.critical);
    });

    test('returns completed status when all topics done', () {
      final examDate = DateTime(2026, 10, 20);
      final result = ExamVelocityEngine.calculate(
        totalTopics: 15,
        completedTopics: 15,
        examDate: examDate,
        currentDate: fixedToday,
      );

      expect(result.remainingTopics, 0);
      expect(result.requiredVelocity, 0.0);
      expect(result.status, VelocityStatus.completed);
      expect(result.completionPercentage, 1.0);
    });

    test('handles exam day (0 days remaining)', () {
      final result = ExamVelocityEngine.calculate(
        totalTopics: 10,
        completedTopics: 8,
        examDate: fixedToday,
        currentDate: fixedToday,
      );

      expect(result.daysRemaining, 0);
      expect(result.remainingTopics, 2);
      expect(result.status, VelocityStatus.overdue);
    });
  });
}
