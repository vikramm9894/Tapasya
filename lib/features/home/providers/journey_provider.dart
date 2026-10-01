import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/journey_repository_impl.dart';
import '../../../domain/models/journey_model.dart';
import '../../../domain/repositories/journey_repository.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepositoryImpl();
});

final activeJourneyProvider = StreamProvider<JourneyModel?>((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.watchActiveJourney();
});
