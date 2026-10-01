import 'package:home_widget/home_widget.dart';

/// Syncs core consistency metrics to the native Android Home Screen AppWidget.
class HomeWidgetSync {
  HomeWidgetSync._();

  static const String appGroupId = 'group.com.vikram.tapasya';
  static const String androidWidgetName = 'TapasyaAppWidgetProvider';

  static Future<void> updateWidgetData({
    required int dayNumber,
    required int streakDays,
    required int currentScore,
    required List<String> top3Tasks,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>('day_number', dayNumber);
      await HomeWidget.saveWidgetData<int>('streak_days', streakDays);
      await HomeWidget.saveWidgetData<int>('current_score', currentScore);

      for (var i = 0; i < 3; i++) {
        final taskName = i < top3Tasks.length ? top3Tasks[i] : '';
        await HomeWidget.saveWidgetData<String>('task_${i + 1}', taskName);
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'TapasyaWidget',
      );
    } catch (_) {
      // Ignored if widget not added to homescreen yet
    }
  }
}
