# Tapasya (तपस्या) — Master Architecture & AI Handover Guide

> **Tagline:** *Roz thoda. 90 din tak.* (Daily discipline. 90 days. One mission.)  
> **Platform:** Android (Flutter 3.x / Dart 3.x), strictly Offline-First  
> **Repository:** `https://github.com/vikramm9894/Tapasya` (Branch: `main`)  
> **Author:** Vikram Nishad (`vikramnishad9894@gmail.com`)  
> **Architecture:** Feature-First Clean Architecture (Presentation $\to$ Domain $\to$ Data)  

---

## 1. Executive Summary & Vision

**Tapasya** is a psychologically grounded consistency and transformation app designed for the Indian student and young professional preparing for high-stakes missions (e.g., UPSC, GATE, Placement, Winter Arc, Fitness, Coding).

Unlike conventional habit trackers that blindly punish users with zero streaks and cause app abandonment, Tapasya introduces **Compassionate Rigor**:
1. **Smart Streak Engine:** Streaks are **never** stored as mutable numbers. They are dynamically derived from chronological daily logs. Features **Bare Minimum Mode** (bad days), **Planned Rest Days**, and **Auto-Freezes** (max 2/month) with **Phoenix Recovery** (2 consecutive success days restore streak with a 3-day penalty).
2. **Morning-Day-Night Feedback Loop:**
   - **Morning Sheet:** Pick Top 3 Non-Negotiables.
   - **Day Mode:** Quick-tap habit execution with haptic feedback + 25-minute Pomodoro focus timer with exam syllabus tracking.
   - **Night Review Sheet:** Reflection (Mood 1-5, Energy 1-5, Focus 1-5, Sleep hours, Win/Issue/Tomorrow journal) that locks in the day's score with a +10% bonus.
3. **Data Sovereignty:** 100% offline-first. Zero cloud leak, zero third-party telemetry, one-tap JSON backup export.

---

## 2. Directory Structure & File Manifest

```
Tapasya/
├── .github/
│   └── workflows/
│       └── flutter_ci.yml             # GitHub Actions CI: Java 17, Flutter 3.22, lint & 7 test suites
├── android/                           # Complete Native Android Host (API 34, Min SDK 24)
│   ├── app/
│   │   ├── build.gradle               # Desugaring, Java 17, Proguard minification, namespace com.tapasya.app
│   │   ├── proguard-rules.pro         # Rules for Drift SQLite, WorkManager, LocalAuth
│   │   └── src/main/
│   │       ├── AndroidManifest.xml    # Exact alarms, notifications, foreground service, biometrics
│   │       └── kotlin/com/tapasya/app/MainActivity.kt
│   ├── build.gradle
│   ├── settings.gradle
│   └── key.properties.example        # Keystore template for release .aab signing
├── docs/
│   ├── RELEASE_CHECKLIST.md           # Play Store release checklist & keystore instructions
│   └── AI_HANDOVER_GUIDE.md           # This master documentation
├── lib/
│   ├── main.dart                      # App entry point, Riverpod ProviderScope, GoRouter
│   ├── core/
│   │   ├── backup/backup_service.dart          # Offline JSON database export & share
│   │   ├── constants/constants.dart            # XP tables, streak thresholds, theme constants
│   │   ├── notifications/notification_service.dart # Local notifications capped at <= 3/day
│   │   ├── router/app_router.dart              # GoRouter: shell routes, modals & deep linking
│   │   ├── security/biometric_service.dart     # LocalAuth fingerprint/face authentication
│   │   ├── theme/app_theme.dart                # Dark slate (#0F0F14), Cyan (#00E5FF), Ember (#FF3D00)
│   │   └── utils/date_utils.dart               # Local YYYY-MM-DD ISO string formatters
│   ├── data/
│   │   ├── database/app_database.dart          # Drift SQLite database singleton
│   │   ├── tables/schema.dart                  # 12 Drift tables definitions
│   │   └── repositories/                       # Repository implementations (Habits, Logs, Focus, Journey)
│   ├── domain/
│   │   ├── engines/                            # 100% PURE DART (Zero Flutter dependencies, 100% testable)
│   │   │   ├── streak_engine.dart              # Mathematical derivation of streaks & recovery
│   │   │   ├── score_engine.dart               # Daily score (65% NN + 25% Bonus + 10% Checkin)
│   │   │   ├── xp_engine.dart                  # Level curves, multipliers, daily caps
│   │   │   ├── insight_engine.dart             # Rule-based offline statistical correlation
│   │   │   ├── adaptive_goal_engine.dart       # 14-day completion rate target adjustment
│   │   │   └── exam_velocity_engine.dart       # Remaining topics / days countdown & pace status
│   │   ├── models/                             # Immutable data entities
│   │   └── repositories/                       # Abstract repository contracts
│   ├── features/
│   │   ├── onboarding/                         # 4-step wizard: Philosophy, Why Anchor, Habits, Commitment
│   │   ├── home/                               # Today tab: Score ring, Top 3 Non-Negotiables, Quick pills
│   │   ├── morning_routine/                    # Morning prioritization modal sheet
│   │   ├── night_review/                       # Evening reflection modal with score lock-in
│   │   ├── habits/                             # Habit CRUD, Stacking (If-Then cues), Min-Value setup
│   │   ├── focus/                              # Pomodoro timer (25/5), subject selector, auto-log
│   │   ├── exam_mode/                          # Exam velocity tracker, countdown, syllabus checklist
│   │   ├── progress/                           # 90-day heatmap matrix, DayDetail modal, trend charts
│   │   ├── weekly_review/                      # Sunday review card & rule-based adaptive prompts
│   │   ├── challenges/                         # Weekly Boss battle ("Procrastination Titan") & Sprints
│   │   ├── profile/                            # Level progress, XP bar, Season Recap card, Badges
│   │   └── settings/                           # Biometric lock, Notification schedule, Rest day, Export JSON
│   └── background/
│       ├── workmanager_callback.dart           # 12:05 AM midnight rollover & auto-freeze job
│       └── widget_sync.dart                    # Android HomeWidget synchronization
├── test/
│   └── engines/                                # Complete unit test suite for all pure engines
│       ├── streak_engine_test.dart
│       ├── score_engine_test.dart
│       ├── xp_engine_test.dart
│       ├── insight_engine_test.dart
│       ├── adaptive_goal_engine_test.dart
│       ├── date_edge_cases_test.dart
│       └── exam_velocity_engine_test.dart
└── web/                                        # Zero-dependency browser simulator (Node.js)
    ├── index.html
    ├── style.css
    ├── app.js
    └── server.js                               # Local preview daemon running on http://localhost:3000
```

---

## 3. Strict Non-Negotiable Engineering Rules

Any AI or developer continuing work on this codebase **MUST** respect these 5 core tenets:

1. **Date Standard:** All calendar daily logs must be stored as **`TEXT` in ISO format (`YYYY-MM-DD`) based on the user's local timezone**. Storing daily log dates in UTC timestamps is strictly forbidden because it causes midnight crossover bugs where habits completed at 11:30 PM shift to the next day.
2. **Derived Streaks:** Streaks are **never** stored as a raw mutable integer counter. They must always be computed on the fly by `StreakEngine.currentStreak(logs)`.
3. **Pure Domain Isolation:** All business logic, algorithms, and scoring must live in `lib/domain/engines/` as pure Dart functions with zero Flutter UI imports.
4. **Anti-Spam Notification Guarantee:** Daily notifications must never exceed 3 alerts per day under any circumstances.
5. **Sleep Guardrail:** Sleep hours in the Night Review sheet cannot be set below 6.0 hours.

---

## 4. Business Logic & Mathematical Formulas

### 4.1 Daily Score Engine (`lib/domain/engines/score_engine.dart`)
$$\text{Score} = \text{clamp}\Big(\big(0.65 \times \frac{\text{NN}_{\text{done}}}{\text{NN}_{\text{total}}} + 0.25 \times \frac{\text{Bonus}_{\text{done}}}{\text{Bonus}_{\text{total}}} + 0.10 \times \text{CheckedIn}\big) \times 100, 0, 100\Big)$$

### 4.2 XP & Progression Engine (`lib/domain/engines/xp_engine.dart`)
- **Base XP by difficulty:** Easy = 10 XP, Medium = 20 XP, Hard = 30 XP.
- **Non-Negotiable Multiplier:** $1.5\times$.
- **Bare Minimum Multiplier:** $0.5\times$.
- **Night Review Bonus:** +10 XP.
- **Perfect Day Bonus (Score $\ge 90$):** +40 XP.
- **Daily XP Cap:** 300 XP (prevents gaming).
- **Level Curve:** $\text{xpToNext}(\text{level}) = 500 + 150 \times (\text{level} - 1)$.
- **Rank Titles:** Level 1–4: Frost Rookie, Level 5–9: Ice Walker, Level 10–14: Snow Warrior, Level 15–19: Blizzard Master, Level 20+: Tapasvi (तपस्वी).

### 4.3 Smart Streak Engine (`lib/domain/engines/streak_engine.dart`)
- **Success Day:** `mode == 'bare_min'` OR `score >= 70` OR `allNnDone == true`.
- **Rest / Freeze Day:** Preserves streak without incrementing or resetting. Auto-freeze limit: 2 per calendar month.
- **Miss Day:** If auto-freezes exhausted, streak enters `Recovery` state.
- **Phoenix Recovery:** Completing 2 consecutive success days restores the broken streak with a 3-day penalty instead of resetting to 0.

### 4.4 Exam Velocity Engine (`lib/domain/engines/exam_velocity_engine.dart`)
$$\text{Velocity} = \frac{\text{Total Topics} - \text{Completed Topics}}{\text{Days Remaining}}$$
- $\le 1.0$ topics/day: `VelocityStatus.comfortable` ("On Track")
- $1.1$ to $2.5$ topics/day: `VelocityStatus.moderate` ("Steady Focus Required")
- $> 2.5$ topics/day: `VelocityStatus.critical` ("Acceleration Required")

---

## 5. Database Schema (12 Drift SQLite Tables)

Located in [`lib/data/tables/schema.dart`](file:///c:/Users/vikra/OneDrive/Desktop/Tapasya/lib/data/tables/schema.dart):
1. `journeys`: Mission tracking (id, start_date, length_days [30/60/90], why_text, letter_text, status).
2. `habits`: Definitions (id, name, category, kind [check/count/duration], target_value, min_value, difficulty [1-3], cue_text, is_active).
3. `habit_entries`: Daily log (id, habit_id, date ['YYYY-MM-DD'], value, completed, source).
4. `daily_priorities`: Top 3 priority slots (date, habit_id, slot [1-3]).
5. `daily_logs`: Master day record (date PK, score [0-100], mode [normal/bare_min/rest/freeze], xp_earned).
6. `checkins`: Evening review (date PK, mood [1-5], energy [1-5], focus [1-5], sleep_hours, win, issue, tomorrow).
7. `subjects`: Study/work categories (id, name, color, exam_date).
8. `exam_topics`: Topics checklist (id, subject_id, title, done, done_on).
9. `focus_sessions`: Deep work sessions (id, subject_id, started_at, duration_sec, completed).
10. `xp_events`: Audit log of all awarded XP (id, date, source, amount, ref_id).
11. `freezes`: Auto-freeze utilization (id, month ['YYYY-MM'], used_on_date).
12. `challenges` & `challenge_days`: Boss battles & sprints (7d, 30d, weekly_boss).

---

## 6. How to Run & Validate

### A. Web Simulator (No Flutter SDK needed)
The repo includes a self-contained Node.js web simulator with identical business logic:
```bash
node web/server.js
# Open http://localhost:3000 in your browser
```

### B. Flutter Mobile Execution
```bash
# Get dependencies
flutter pub get

# Run all pure domain unit tests
flutter test test/engines/

# Generate Drift code (if schema modified)
dart run build_runner build --delete-conflicting-outputs

# Run on Android emulator / physical device
flutter run

# Build production Android App Bundle for Google Play Store
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 7. Recommended Next Steps for V2 (Future Scope)

When extending Tapasya beyond V1.0:
1. **Optional Cloud Backup (Opt-In):** Implement encrypted sync with Firebase Auth / Firestore or Supabase while strictly preserving the offline-first guarantee.
2. **Accountability Partner Link:** Allow users to generate a 6-digit link code to share streak status and daily scores with a friend without exposing private journal entries.
3. **AI Journal Coach (Claude 3.5 Sonnet / Gemini):** Add an opt-in button in the Sunday Weekly Review that analyzes the user's weekly wins/issues and provides personalized, compassionate advice.
4. **Focus Soundscapes:** Built-in offline ambient audio generator (binaural beats, monsoon rain, brown noise) for the Pomodoro timer.
