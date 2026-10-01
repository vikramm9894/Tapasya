import 'package:intl/intl.dart';

/// Date utility methods strictly enforcing the local timezone standard.
/// All daily logs and streak calculations MUST use local YYYY-MM-DD representation.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');
  static final DateFormat _displayFormat = DateFormat('EEE, d MMM');

  /// Returns today's date formatted as 'YYYY-MM-DD' in local timezone.
  static String todayKey() {
    return _isoDateFormat.format(DateTime.now());
  }

  /// Returns yesterday's date formatted as 'YYYY-MM-DD' in local timezone.
  static String yesterdayKey() {
    final now = DateTime.now();
    return _isoDateFormat.format(now.subtract(const Duration(days: 1)));
  }

  /// Formats any [DateTime] as 'YYYY-MM-DD'.
  static String toKey(DateTime date) {
    return _isoDateFormat.format(date);
  }

  /// Formats any [DateTime] as 'YYYY-MM' (for freeze tracking).
  static String toMonthKey(DateTime date) {
    return _monthFormat.format(date);
  }

  /// Returns current month as 'YYYY-MM'.
  static String currentMonthKey() {
    return _monthFormat.format(DateTime.now());
  }

  /// Parses a 'YYYY-MM-DD' key into a [DateTime] in local timezone.
  static DateTime parseKey(String key) {
    return _isoDateFormat.parseStrict(key);
  }

  /// Formats a key for human presentation (e.g. 'Tue, 14 Oct').
  static String toDisplayString(String key) {
    final date = parseKey(key);
    return _displayFormat.format(date);
  }

  /// Calculates days elapsed between start date and current date (1-indexed).
  static int calculateDayNumber(String startDateKey, String currentDateKey) {
    final start = parseKey(startDateKey);
    final current = parseKey(currentDateKey);
    return current.difference(start).inDays + 1;
  }
}
