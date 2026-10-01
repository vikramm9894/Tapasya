import 'dart:async';
import '../../domain/models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final List<HabitModel> _cachedHabits = [];
  final StreamController<List<HabitModel>> _streamController = StreamController<List<HabitModel>>.broadcast();

  HabitRepositoryImpl({List<HabitModel>? initialHabits}) {
    if (initialHabits != null && initialHabits.isNotEmpty) {
      _cachedHabits.addAll(initialHabits);
    }
  }

  void _notify() {
    final active = _cachedHabits.where((h) => h.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _streamController.add(active);
  }

  @override
  Stream<List<HabitModel>> watchActiveHabits() async* {
    final active = _cachedHabits.where((h) => h.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    yield active;
    yield* _streamController.stream;
  }

  @override
  Future<List<HabitModel>> getActiveHabits() async {
    return _cachedHabits.where((h) => h.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    try {
      return _cachedHabits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createHabit(HabitModel habit) async {
    _cachedHabits.add(habit);
    _notify();
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final index = _cachedHabits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _cachedHabits[index] = habit;
      _notify();
    }
  }

  @override
  Future<void> archiveHabit(String id) async {
    final index = _cachedHabits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _cachedHabits[index] = _cachedHabits[index].copyWith(
        isActive: false,
        archivedAt: DateTime.now().toIso8601String(),
      );
      _notify();
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    _cachedHabits.removeWhere((h) => h.id == id);
    _notify();
  }

  @override
  Future<void> createInitialHabits(List<HabitModel> habits) async {
    _cachedHabits.addAll(habits);
    _notify();
  }

  void dispose() {
    _streamController.close();
  }
}
