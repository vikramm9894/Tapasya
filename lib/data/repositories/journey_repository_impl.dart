import 'dart:async';
import '../../domain/models/journey_model.dart';
import '../../domain/repositories/journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  JourneyModel? _activeJourney;
  final StreamController<JourneyModel?> _streamController = StreamController<JourneyModel?>.broadcast();

  JourneyRepositoryImpl({JourneyModel? initialJourney}) {
    _activeJourney = initialJourney;
  }

  void _notify() {
    _streamController.add(_activeJourney);
  }

  @override
  Stream<JourneyModel?> watchActiveJourney() async* {
    yield _activeJourney;
    yield* _streamController.stream;
  }

  @override
  Future<JourneyModel?> getActiveJourney() async {
    return _activeJourney;
  }

  @override
  Future<void> createJourney(JourneyModel journey) async {
    _activeJourney = journey;
    _notify();
  }

  @override
  Future<void> updateJourney(JourneyModel journey) async {
    _activeJourney = journey;
    _notify();
  }

  @override
  Future<void> completeJourney(String id) async {
    if (_activeJourney?.id == id) {
      _activeJourney = _activeJourney!.copyWith(status: 'completed');
      _notify();
    }
  }

  @override
  Future<void> abandonJourney(String id) async {
    if (_activeJourney?.id == id) {
      _activeJourney = _activeJourney!.copyWith(status: 'abandoned');
      _notify();
    }
  }

  void dispose() {
    _streamController.close();
  }
}
