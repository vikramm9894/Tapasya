/// Application-wide constants for Tapasya.
class AppConstants {
  AppConstants._();

  static const String appName = 'Tapasya';
  static const String tagline = 'Roz thoda. 90 din tak.';

  // Journey lengths
  static const List<int> supportedJourneyLengths = [30, 60, 90];
  static const int defaultJourneyDays = 90;

  // Streak & Freeze constraints
  static const int maxFreezesPerMonth = 2;
  static const int recoveryPenaltyDays = 3;

  // XP & Gamification
  static const int dailyXpCap = 300;
  static const int perfectDayBonusXp = 40;

  // Wellness constraints
  static const double minSleepHours = 6.0;
  static const double maxSleepHours = 12.0;

  // Categories
  static const List<String> habitCategories = [
    'Study',
    'Fitness',
    'Health',
    'Mindset',
    'Work',
  ];
}
