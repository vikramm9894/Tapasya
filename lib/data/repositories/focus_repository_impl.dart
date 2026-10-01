import 'dart:async';
import '../../core/utils/date_utils.dart';
import '../../domain/models/exam_topic_model.dart';
import '../../domain/models/focus_session_model.dart';
import '../../domain/models/subject_model.dart';
import '../../domain/repositories/focus_repository.dart';

class FocusRepositoryImpl implements FocusRepository {
  final List<SubjectModel> _subjects = [
    SubjectModel(
      id: 'sub_1',
      name: 'Computer Science',
      colorHex: '#00E5FF',
      examDate: AppDateUtils.toKey(DateTime.now().add(const Duration(days: 14))),
    ),
    const SubjectModel(
      id: 'sub_2',
      name: 'Mathematics',
      colorHex: '#FFB300',
    ),
    const SubjectModel(
      id: 'sub_3',
      name: 'Deep Reading',
      colorHex: '#7C4DFF',
    ),
    const SubjectModel(
      id: 'sub_4',
      name: 'System Design',
      colorHex: '#00E676',
    ),
  ];

  final List<FocusSessionModel> _sessions = [];

  final List<ExamTopicModel> _topics = [
    const ExamTopicModel(id: 't1', subjectId: 'sub_1', title: 'Binary Trees & BFS/DFS', done: true, doneOn: '2026-10-01'),
    const ExamTopicModel(id: 't2', subjectId: 'sub_1', title: 'Dynamic Programming Foundations', done: true, doneOn: '2026-10-01'),
    const ExamTopicModel(id: 't3', subjectId: 'sub_1', title: 'Graph Shortest Path (Dijkstra)', done: false),
    const ExamTopicModel(id: 't4', subjectId: 'sub_1', title: 'B-Trees & Database Indexing', done: false),
    const ExamTopicModel(id: 't5', subjectId: 'sub_1', title: 'Concurrency & Deadlock Resolution', done: false),
  ];

  final StreamController<List<SubjectModel>> _subjectsController = StreamController.broadcast();
  final StreamController<List<FocusSessionModel>> _sessionsController = StreamController.broadcast();
  final StreamController<List<ExamTopicModel>> _topicsController = StreamController.broadcast();

  @override
  Stream<List<SubjectModel>> watchSubjects() async* {
    yield _subjects;
    yield* _subjectsController.stream;
  }

  @override
  Future<List<SubjectModel>> getSubjects() async => _subjects;

  @override
  Future<void> addSubject(SubjectModel subject) async {
    _subjects.add(subject);
    _subjectsController.add(_subjects);
  }

  @override
  Stream<List<FocusSessionModel>> watchTodaySessions() async* {
    yield _sessions;
    yield* _sessionsController.stream;
  }

  @override
  Future<void> recordCompletedSession(FocusSessionModel session) async {
    _sessions.add(session);
    _sessionsController.add(_sessions);
  }

  @override
  Stream<List<ExamTopicModel>> watchTopicsForSubject(String subjectId) async* {
    yield _topics.where((t) => t.subjectId == subjectId).toList();
    yield* _topicsController.stream.map((list) => list.where((t) => t.subjectId == subjectId).toList());
  }

  @override
  Future<void> toggleTopicDone(String topicId, bool isDone) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index != -1) {
      _topics[index] = _topics[index].copyWith(
        done: isDone,
        doneOn: isDone ? AppDateUtils.todayKey() : null,
      );
      _topicsController.add(_topics);
    }
  }

  @override
  Future<void> addTopic(ExamTopicModel topic) async {
    _topics.add(topic);
    _topicsController.add(_topics);
  }

  void dispose() {
    _subjectsController.close();
    _sessionsController.close();
    _topicsController.close();
  }
}
