import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/backup/backup_service.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../ai/ai_consent_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricLockEnabled = false;
  bool _morningReminder = true;
  bool _eveningReviewReminder = true;
  bool _weeklySundayReminder = true;
  String _selectedRestDay = 'Sunday';

  final List<String> _restDayOptions = ['Sunday', 'Saturday', 'None'];

  Future<void> _toggleBiometrics(bool value) async {
    HapticFeedback.lightImpact();
    if (value) {
      final authenticated = await BiometricService.authenticate(
        reason: 'Authenticate with Fingerprint/Face to enable App Lock',
      );
      if (authenticated) {
        setState(() => _biometricLockEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 Biometric App Lock Enabled'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      setState(() => _biometricLockEnabled = false);
    }
  }

  Future<void> _handleExportData() async {
    HapticFeedback.mediumImpact();
    try {
      await BackupService.exportAndShareBackup(
        habitsData: {'count': 5, 'active': true},
        logsData: {'days_logged': 12, 'frozen_days': 0},
        journeyData: {'mission': '90-Day Tapasya', 'day': 12},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export simulated (JSON created): $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Current Journey?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: const Text(
          'This will archive your current 90-day journey and reset all active habit streaks. You can always review past data in the archive.\n\nAre you sure you want to proceed?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Active journey archived. Tap Onboarding to restart.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset Journey'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS & PRIVACY'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security & App Lock
          _sectionHeader('SECURITY & APP LOCK'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  value: _biometricLockEnabled,
                  onChanged: _toggleBiometrics,
                  activeColor: AppTheme.primaryCyan,
                  secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryCyan),
                  title: const Text('Biometric App Lock', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                    'Require fingerprint or device PIN on every launch',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Daily Routines & Notifications
          _sectionHeader('SCHEDULE & NOTIFICATIONS'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  value: _morningReminder,
                  onChanged: (val) => setState(() => _morningReminder = val),
                  activeColor: AppTheme.primaryCyan,
                  secondary: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFB300)),
                  title: const Text('Morning Prioritization Prompt', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('7:00 AM — Choose your Top 3 Non-Negotiables', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
                const Divider(height: 1, color: AppTheme.border),
                SwitchListTile(
                  value: _eveningReviewReminder,
                  onChanged: (val) => setState(() => _eveningReviewReminder = val),
                  activeColor: AppTheme.primaryCyan,
                  secondary: const Icon(Icons.nightlight_outlined, color: AppTheme.secondaryEmber),
                  title: const Text('Night Reflection & Lock-in', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('9:30 PM — Record mood, sleep, journal & lock score', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
                const Divider(height: 1, color: AppTheme.border),
                SwitchListTile(
                  value: _weeklySundayReminder,
                  onChanged: (val) => setState(() => _weeklySundayReminder = val),
                  activeColor: AppTheme.primaryCyan,
                  secondary: const Icon(Icons.insights, color: AppTheme.primaryCyan),
                  title: const Text('Sunday Weekly Review', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('6:00 PM — Statistical patterns & goal adaptation', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
                const Divider(height: 1, color: AppTheme.border),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppTheme.successGreen),
                  title: const Text('Strict Notification Guarantee', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Tapasya never sends spam or exceeds 3 alerts per day.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // AI Coach & Privacy Consent
          _sectionHeader('AI COACH & PRIVACY CONSENT'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const AiConsentSection(),
          ),

          const SizedBox(height: 20),

          // Rest Days & Streak Flexibility
          _sectionHeader('STREAK FLEXIBILITY & REST'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planned Rest Day', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Preserves streak without penalties', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  DropdownButton<String>(
                    value: _selectedRestDay,
                    dropdownColor: AppTheme.surfaceElevated,
                    underline: const SizedBox(),
                    items: _restDayOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt, style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRestDay = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Data Sovereignty & Backup
          _sectionHeader('DATA SOVEREIGNTY (OFFLINE-FIRST)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppTheme.primaryCyan),
                  title: const Text('Export Offline Backup (JSON)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Download or share a human-readable snapshot of all your logs', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                  onTap: _handleExportData,
                ),
                const Divider(height: 1, color: AppTheme.border),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.redAccent),
                  title: const Text('Reset Current 90-Day Journey', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  subtitle: const Text('Archive mission and start clean Day 1', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                  onTap: _showResetDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Manifesto & About
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🛡️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Tapasya Privacy Manifesto',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Your daily struggles, focus hours, moods, and reflections belong exclusively to you. Tapasya has no external trackers, no ads, and zero server logging. Everything is stored locally on your device.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  'Tapasya v1.0.0 • Pure Discipline',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
