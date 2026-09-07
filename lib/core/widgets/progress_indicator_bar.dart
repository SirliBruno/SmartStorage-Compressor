import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Smooth animated progress bar with percentage readout and ETA display.
class ProgressIndicatorBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? etaText;
  final Color? barColor;
  final double height;

  const ProgressIndicatorBar({
    super.key,
    required this.progress,
    this.etaText,
    this.barColor,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentInt = (clampedProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentInt%',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
            if (etaText != null)
              Text(
                etaText!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: AppColors.surfaceHighlight,
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                widthFactor: clampedProgress,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: barColor ?? AppColors.primary,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
