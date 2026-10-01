import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/habit_repository_impl.dart';
import '../../../domain/models/habit_model.dart';
import '../../../domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  // Pre-loaded seed habits for demonstration
  return HabitRepositoryImpl(
    initialHabits: const [
      HabitModel(
        id: 'h1',
        name: 'Deep Study: Data Structures',
        category: 'Study',
        kind: 'duration',
        targetValue: 60.0,
        minValue: 20.0,
        unit: 'min',
        difficulty: 3,
        cueText: 'Chai ke baad 1 ghanta desk par',
        sortOrder: 1,
      ),
      HabitModel(
        id: 'h2',
        name: 'Morning 45-min Gym / Running',
        category: 'Fitness',
        kind: 'duration',
        targetValue: 45.0,
        minValue: 15.0,
        unit: 'min',
        difficulty: 3,
        cueText: 'Uthte hi workout clothes pehno',
        sortOrder: 2,
      ),
      HabitModel(
        id: 'h3',
        name: 'Read 15 Pages of Book',
        category: 'Mindset',
        kind: 'count',
        targetValue: 15.0,
        minValue: 5.0,
        unit: 'pages',
        difficulty: 2,
        cueText: 'Dinner ke baad bed par',
        sortOrder: 3,
      ),
      HabitModel(
        id: 'h4',
        name: '10-min Mindfulness Meditation',
        category: 'Health',
        kind: 'duration',
        targetValue: 10.0,
        minValue: 5.0,
        unit: 'min',
        difficulty: 1,
        cueText: 'Subah uthte hi 10 min silence',
        sortOrder: 4,
      ),
      HabitModel(
        id: 'h5',
        name: 'Zero Sugar & Clean Diet',
        category: 'Health',
        kind: 'check',
        targetValue: 1.0,
        minValue: 1.0,
        difficulty: 2,
        cueText: 'Din bhar conscious discipline',
        sortOrder: 5,
      ),
    ],
  );
});

final activeHabitsProvider = StreamProvider<List<HabitModel>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchActiveHabits();
});
