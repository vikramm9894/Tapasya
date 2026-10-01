# Tapasya (तपस्या) — 90-Day Consistency App
## Master Implementation Plan & Engineering Blueprint

> **Tagline:** *Roz thoda. 90 din tak.* (Daily discipline. 90 days. One mission.)  
> **Platform:** Android (Flutter 3.x), Offline-First  
> **Architecture:** Feature-First Clean Architecture (Riverpod + Drift SQLite)  
> **Target Timeline:** 8–10 weeks (~10 hours/week)

---

## 1. Executive Summary & Vision

**Tapasya** is an offline-first, psychologically sound consistency app built around the concept of a 90-day disciplined transformation ("Winter Arc" / "Tapasya"). Unlike standard habit trackers that punish users with streak loss and cause disengagement, Tapasya introduces a **compassionate yet rigorous consistency loop**:
- **Smart Streak Engine:** Streaks are mathematically computed from immutable daily logs, never stored as raw counters. Incorporates Bare Minimum Mode, Planned Rest Days, and Auto-Freeze (max 2/month) with Streak Recovery mechanics.
- **Morning-Day-Night Feedback Loop:** Morning priority commitment (Top 3 Non-Negotiables), Daytime quick-tap execution with haptic feedback, and Night Review for reflection and lock-in.
- **Deep Study / Work Integration:** Built-in Focus Timer (Pomodoro 25/5) with Subject Tracking and auto-logging to habit logs, plus Exam Mode countdown and daily topic velocity.
- **Rule-Based Insight Engine:** Offline correlation analysis (sleep vs. focus, morning routine vs. completion) with zero external privacy risks.

---

## 2. System Architecture & Project Structure

The project follows a **Feature-First Clean Architecture** with strict isolation of business logic into pure Dart domain engines. UI widgets never directly interact with databases; all mutations flow through Riverpod Notifiers and Repositories.

```
lib/
├── core/
│   ├── constants/            # XP constants, streak thresholds, colors, typography
│   ├── database/             # AppDatabase singleton, schema versioning, migrations
│   ├── notifications/        # NotificationService, channel definitions, action handlers
│   ├── router/               # go_router configuration with deep-link routes
│   ├── theme/                # Dark/Light theme, glassmorphic styles, custom palettes
│   └── utils/                # DateUtils (YYYY-MM-DD local formatting), haptics, formatters
├── data/
│   ├── daos/                 # HabitDao, DailyLogDao, FocusDao, JourneyDao, FreezeDao
│   ├── tables/               # Drift table schemas
│   └── repositories/         # HabitRepositoryImpl, JourneyRepositoryImpl, etc.
├── domain/
│   ├── engines/              # PURE DART (No Flutter imports - 100% testable)
│   │   ├── streak_engine.dart
│   │   ├── xp_engine.dart
│   │   ├── score_engine.dart
│   │   ├── insight_engine.dart
│   │   └── adaptive_goal_engine.dart
│   ├── models/               # Freezed domain entities & value objects
│   └── repositories/         # Abstract repository interfaces
├── features/
│   ├── onboarding/           # Welcome, Why Statement, Day-90 Letter, Initial Habit Setup
│   ├── home/                 # Today view, score ring, 3 non-negotiables, quick-tap
│   ├── morning_routine/      # Morning prioritization modal (Top 3 selection)
│   ├── night_review/         # Evening check-in modal (Mood, Sleep, Focus, 3-line journal)
│   ├── habits/               # Habit CRUD, Habit stacking (If-Then cues), Min-Value setup
│   ├── focus/                # Pomodoro timer, Subject selector, Foreground service
│   ├── exam_mode/            # Subject exam tracker, topic velocity calculator
│   ├── progress/             # 90-day heatmap calendar, weekly bar charts, habit trends
│   ├── weekly_review/        # Sunday review card, AI-free rule-based insights, adaptive prompts
│   ├── challenges/           # 7/30-day challenges, Weekly Boss battles
│   ├── profile/              # Level status, XP bar, achievement gallery, Season Recap card
│   └── settings/             # Biometric lock, export JSON/CSV, rest-day schedule, notifications
└── background/
    ├── workmanager_callback.dart  # Midnight rollover job, weekly review scheduler
    └── widget_sync.dart           # HomeWidget data updater
```

---

## 3. Database Schema (Drift / SQLite)

> **Strict Date Storage Standard:** All dates representing a calendar day must be stored as **`TEXT` in ISO format (`YYYY-MM-DD`) based on the user's local timezone**. Storing calendar dates in UTC timestamps creates timezone boundary bugs where a habit completed at 11:30 PM gets logged onto the next day. Timestamps (`DateTime`) are only used for exact session intervals (e.g. `started_at` in `focus_sessions`).

### Tables Overview
1. **`journeys`**: Active mission, start date, 30/60/90 days length, why text, locked Day-90 letter.
2. **`habits`**: Habit definitions, kinds (check/count/duration), target & min values, difficulty (1-3), cues.
3. **`habit_entries`**: Daily record per habit, actual value, completed status, source (manual/timer/health).
4. **`daily_priorities`**: Top 3 daily Non-Negotiable slots.
5. **`daily_logs`**: Primary key `date` (`YYYY-MM-DD`), mode (normal, bare_min, rest, freeze), daily score (0-100), XP.
6. **`checkins`**: Night review metrics (mood, energy, focus 1-5, sleep hours, 3-line journal).
7. **`subjects` & `exam_topics`**: Exam preparation tracking and velocity calculation.
8. **`focus_sessions`**: Deep work sessions linked to subjects with duration and timestamps.
9. **`xp_events`**: Audit log of earned XP events.
10. **`freezes`**: Auto-freeze utilization tracking (max 2/calendar month).
11. **`challenges` & `challenge_days`**: 7-day, 30-day, and Weekly Boss challenges.
12. **`achievements` & `settings`**: Unlocked badges and persistent user configurations.

---

## 4. Pure Domain Engines (Business Logic Specification)

All calculation engines remain **100% pure Dart functions with zero Flutter UI dependencies** for maximum testability.

### 4.1 Daily Score Engine
```dart
int dailyScore({
  required int nnDone,
  required int nnTotal,
  required int bonusDone,
  required int bonusTotal,
  required bool checkedIn,
}) {
  final nn = nnTotal == 0 ? 0.0 : nnDone / nnTotal;
  final bonus = bonusTotal == 0 ? 0.0 : bonusDone / bonusTotal;
  final raw = 0.65 * nn + 0.25 * bonus + (checkedIn ? 0.10 : 0.0);
  return (raw * 100).round().clamp(0, 100);
}
```

### 4.2 XP & Level Progression Engine
- Base XP by difficulty: Easy = 10, Medium = 20, Hard = 30.
- Non-negotiable multiplier: 1.5×.
- Bare Minimum multiplier: 0.5×.
- Perfect Day bonus: +40 XP. Daily Cap: 300 XP.
- Level threshold: `xpToNext(level) = 500 + 150 * (level - 1)`.

### 4.3 Smart Streak Engine
- **Success:** `mode == 'bare_min'` OR `score >= 70` OR `allNnDone == true`.
- **Rest / Freeze:** Preserves streak without incrementing or resetting.
- **Miss:** Consumes 1 of 2 monthly freezes. If no freezes left, enters Recovery state (2 consecutive success days restores streak minus 3 days penalty).

### 4.4 Insight & Adaptive Goals Engines
- Rule-based statistical correlation (e.g. sleep $\ge 7$h vs focus average differential $\ge 0.4$).
- 14-day completion rate: $\ge 85\%$ triggers +25% target increase suggestion; $< 50\%$ triggers -25% reduction suggestion.

---

## 5. UI/UX & Flow Architecture

- **4 Bottom Navigation Tabs:** Today, Progress, Focus, Me.
- **Morning Sheet:** Opens automatically on the first app launch of each day to designate Top 3 Non-Negotiables.
- **Night Review Sheet:** Prompts user at 9:30 PM (or manual tap after 8:00 PM) to record mood, energy, focus, sleep hours, 3-line journal, and locks in the day's score.
- **Focus Timer:** Pomodoro 25/5 with foreground service and persistent status notification. Auto-logs session to corresponding study habit.
- **Exam Mode:** Countdown timer with topic checklist and daily velocity requirement.
- **Season Recap:** Generates shareable 9:16 card at 30, 60, and 90 days.

---

## 6. Development Roadmap & Phased Execution

| Phase | Duration | Scope & Key Deliverables | Status |
| :--- | :--- | :--- | :--- |
| **0. Setup** | Week 0.5 | Flutter 3 scaffold, Drift, Riverpod, go_router, Theme tokens | ✅ **COMPLETED** |
| **1. Foundation** | Weeks 1–2 | Drift tables, DAOs, Habit CRUD, 4-step Onboarding flow | ✅ **COMPLETED** |
| **2. Core Loop** | Weeks 3–4 | Top 3 priorities, Score & Streak engines, Morning/Night sheets | ✅ **COMPLETED** |
| **3. Gamification** | Weeks 5–6 | XP/Level system, Achievements, 90-day Calendar Heatmap | ⏳ In Progress |
| **4. Focus & Alerts** | Week 7 | Pomodoro timer, Exam mode, WorkManager midnight rollover | ⏳ Planned |
| **5. Insights & Polish**| Week 8 | Sunday weekly review, Adaptive suggestions, Home Widgets | ⏳ Planned |
| **6. Beta & Release** | Weeks 9–10 | Unit testing (>95% engine coverage), Closed beta, Play Store | ⏳ Planned |

---

## 7. Anti-Pitfall Checklist

1. **Never store streaks as a mutable counter:** Always derive dynamically from chronological `daily_logs`.
2. **Never store daily log dates in UTC:** Always use ISO string `'YYYY-MM-DD'` in the user's local timezone.
3. **Never defer notifications to the final sprint:** Implement Android 13/12 permissions and foreground services early in Phase 4.
4. **Never mix UI widgets with domain logic:** Keep all mathematical engines in pure Dart (`lib/domain/engines/`) with complete unit test coverage.
5. **Never exceed 3 notifications daily:** Respect user attention and avoid app abandonment.
