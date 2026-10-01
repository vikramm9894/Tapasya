import '../models/habit_model.dart';

abstract class HabitRepository {
  Stream<List<HabitModel>> watchActiveHabits();
  Future<List<HabitModel>> getActiveHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> createHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> archiveHabit(String id);
  Future<void> deleteHabit(String id);
  Future<void> createInitialHabits(List<HabitModel> habits);
}
