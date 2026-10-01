import '../models/journey_model.dart';

abstract class JourneyRepository {
  Stream<JourneyModel?> watchActiveJourney();
  Future<JourneyModel?> getActiveJourney();
  Future<void> createJourney(JourneyModel journey);
  Future<void> updateJourney(JourneyModel journey);
  Future<void> completeJourney(String id);
  Future<void> abandonJourney(String id);
}
