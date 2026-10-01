import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';

/// Shareable 9:16 Season Recap Badge Generator using RepaintBoundary and share_plus.
class SeasonRecapWidget extends StatelessWidget {
  final GlobalKey boundaryKey = GlobalKey();
  final int streakDays;
  final double totalFocusHours;
  final String levelTitle;
  final int currentLevel;
  final double consistencyRate;

  SeasonRecapWidget({
    super.key,
    this.streakDays = 12,
    this.totalFocusHours = 28.5,
    this.levelTitle = 'Ice Walker',
    this.currentLevel = 5,
    this.consistencyRate = 93.4,
  });

  Future<void> exportAndShare(BuildContext context) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/tapasya_recap_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Conquered Day 30 on Tapasya! Roz thoda. 90 din tak. #Tapasya #WinterArc',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting recap: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryCyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ॐ TAPASYA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: AppTheme.primaryCyan,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '30-DAY DISCIPLINE CERTIFICATE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.secondaryEmber,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  '${consistencyRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppTheme.primaryCyan,
                  ),
                ),
                const Text(
                  'CONSISTENCY RATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _recapRow('🔥 Unbroken Streak', '$streakDays Days'),
                      const Divider(color: Colors.white10),
                      _recapRow('⏱️ Deep Focus Logged', '${totalFocusHours}h'),
                      const Divider(color: Colors.white10),
                      _recapRow('⚡ Character Tier', 'Lvl $currentLevel $levelTitle'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Verified On-Device', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    Text('#Tapasya #90Days', style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          icon: const Icon(Icons.share),
          label: const Text('Share to Instagram / WhatsApp'),
          onPressed: () => exportAndShare(context),
        ),
      ],
    );
  }

  Widget _recapRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
