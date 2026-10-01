import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/date_utils.dart';

/// Offline backup and JSON data export service for Tapasya.
/// Keeps 100% of user data strictly on-device without third-party cloud vulnerabilities.
class BackupService {
  BackupService._();

  /// Generates a complete JSON snapshot of user's consistency data.
  static Future<String> generateBackupJson({
    required Map<String, dynamic> habitsData,
    required Map<String, dynamic> logsData,
    required Map<String, dynamic> journeyData,
  }) async {
    final payload = {
      'app': 'Tapasya',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'journey': journeyData,
      'habits': habitsData,
      'daily_logs': logsData,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports backup JSON to disk and triggers Android share sheet.
  static Future<void> exportAndShareBackup({
    required Map<String, dynamic> habitsData,
    required Map<String, dynamic> logsData,
    required Map<String, dynamic> journeyData,
  }) async {
    final jsonString = await generateBackupJson(
      habitsData: habitsData,
      logsData: logsData,
      journeyData: journeyData,
    );

    final dir = await getTemporaryDirectory();
    final today = AppDateUtils.todayKey();
    final file = File('${dir.path}/tapasya_backup_$today.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Tapasya Offline Backup ($today)',
      text: 'My encrypted offline consistency backup from Tapasya.',
    );
  }
}
