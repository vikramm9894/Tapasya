import 'package:drift/drift.dart';

/// Journeys: Represents the 30/60/90 day mission.
class Journeys extends Table {
  TextColumn get id => text()();
  TextColumn get startDate => text()(); // 'YYYY-MM-DD'
  IntColumn get lengthDays => integer().withDefault(const Constant(90))(); // 30, 60, 90
  TextColumn get whyText => text().nullable()();
  TextColumn get letterText => text().nullable()(); // Day-90 letter, locked until completion
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed, abandoned
  TextColumn get theme => text().withDefault(const Constant('default'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Habits: Master catalog of tracked user habits.
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get category => text()(); // health, study, fitness, mindset, work
  TextColumn get kind => text()(); // check, count, duration
  RealColumn get targetValue => real().withDefault(const Constant(1.0))();
  RealColumn get minValue => real().withDefault(const Constant(1.0))(); // Bare Minimum Mode
  TextColumn get unit => text().nullable()(); // 'pages', 'min', 'km'
  IntColumn get difficulty => integer().withDefault(const Constant(2))(); // 1: easy, 2: medium, 3: hard
  TextColumn get cueText => text().nullable()(); // Habit stacking cue: "After morning chai..."
  TextColumn get cueTime => text().nullable()(); // e.g. "07:30"
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get archivedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// HabitEntries: Daily completion log per habit.
@TableIndex(name: 'idx_habit_entries_date', columns: {#date})
@TableIndex(name: 'idx_habit_entries_habit_date', columns: {#habitId, #date})
class HabitEntries extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id)();
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  RealColumn get value => real().withDefault(const Constant(0.0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // manual, timer, health
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [{habitId, date}];
}

/// DailyPriorities: Top 3 Non-Negotiable slots for a given day.
class DailyPriorities extends Table {
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  IntColumn get slot => integer()(); // 1, 2, 3
  TextColumn get habitId => text().references(Habits, #id)();

  @override
  Set<Column> get primaryKey => {date, slot};
}

/// DailyLogs: Immutable daily summary score and streak state.
class DailyLogs extends Table {
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  TextColumn get journeyId => text().nullable().references(Journeys, #id)();
  TextColumn get mode => text().withDefault(const Constant('normal'))(); // normal, bare_min, rest, freeze
  IntColumn get score => integer().withDefault(const Constant(0))(); // 0 - 100
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Checkins: Evening reflection and wellness metrics.
class Checkins extends Table {
  TextColumn get date => text().references(DailyLogs, #date)();
  IntColumn get mood => integer().withDefault(const Constant(3))(); // 1 - 5
  IntColumn get energy => integer().withDefault(const Constant(3))(); // 1 - 5
  IntColumn get focus => integer().withDefault(const Constant(3))(); // 1 - 5
  RealColumn get sleepHours => real().withDefault(const Constant(7.0))();
  TextColumn get win => text().nullable()();
  TextColumn get issue => text().nullable()();
  TextColumn get tomorrow => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

/// Subjects: Study/Work categories for the Focus Timer & Exam Mode.
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#00E5FF'))();
  TextColumn get examDate => text().nullable()(); // 'YYYY-MM-DD'

  @override
  Set<Column> get primaryKey => {id};
}

/// ExamTopics: Topics checklist for Exam Mode velocity calculation.
class ExamTopics extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get doneOn => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// FocusSessions: Pomodoro and deep work session tracking.
@TableIndex(name: 'idx_focus_started', columns: {#startedAt})
class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().nullable().references(Subjects, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSec => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// XpEvents: Audit trail for all awarded XP.
class XpEvents extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  TextColumn get source => text()(); // habit, perfect_day, challenge, review
  IntColumn get amount => integer()();
  TextColumn get refId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Freezes: Auto-freeze tracking (max 2 per calendar month).
class Freezes extends Table {
  TextColumn get id => text()();
  TextColumn get month => text()(); // 'YYYY-MM'
  TextColumn get usedOnDate => text()(); // 'YYYY-MM-DD'

  @override
  Set<Column> get primaryKey => {id};
}

/// Challenges: 7-day, 30-day, and Weekly Boss challenges.
class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get templateKey => text()();
  TextColumn get kind => text()(); // 7d, 30d, weekly_boss, custom
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ChallengeDays: Daily progress check within a challenge.
class ChallengeDays extends Table {
  TextColumn get challengeId => text().references(Challenges, #id)();
  TextColumn get date => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {challengeId, date};
}

/// Achievements: Unlocked behavioral badges.
class Achievements extends Table {
  TextColumn get key => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Settings: User configuration key-value storage.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
