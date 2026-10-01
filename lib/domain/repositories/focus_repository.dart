import '../models/exam_topic_model.dart';
import '../models/focus_session_model.dart';
import '../models/subject_model.dart';

abstract class FocusRepository {
  // Subjects
  Stream<List<SubjectModel>> watchSubjects();
  Future<List<SubjectModel>> getSubjects();
  Future<void> addSubject(SubjectModel subject);

  // Focus Sessions
  Stream<List<FocusSessionModel>> watchTodaySessions();
  Future<void> recordCompletedSession(FocusSessionModel session);

  // Exam Topics
  Stream<List<ExamTopicModel>> watchTopicsForSubject(String subjectId);
  Future<void> toggleTopicDone(String topicId, bool isDone);
  Future<void> addTopic(ExamTopicModel topic);
}
