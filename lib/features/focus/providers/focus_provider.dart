import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/focus_repository_impl.dart';
import '../../../domain/models/exam_topic_model.dart';
import '../../../domain/models/focus_session_model.dart';
import '../../../domain/models/subject_model.dart';
import '../../../domain/repositories/focus_repository.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepositoryImpl();
});

final subjectsProvider = StreamProvider<List<SubjectModel>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchSubjects();
});

final todayFocusSessionsProvider = StreamProvider<List<FocusSessionModel>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchTodaySessions();
});

final examTopicsProvider = StreamProvider.family<List<ExamTopicModel>, String>((ref, subjectId) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchTopicsForSubject(subjectId);
});
